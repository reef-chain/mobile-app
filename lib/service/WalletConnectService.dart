import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/components/modals/wallet_connect_session_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/service/AppLifecycleManager.dart';
import 'package:reef_mobile_app/service/LocalNotificationService.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:permission_handler/permission_handler.dart';

const String PROJECT_ID = 'b20768c469f63321e52923a168155240';
const String SIGN_TX_METHOD = 'reef_signTransaction';
const String SIGN_MSG_METHOD = 'reef_signMessage';
const List<String> supportedMethods = [SIGN_TX_METHOD, SIGN_MSG_METHOD];
const List<String> supportedEvents = []; // Events not supported for now
String MAINNET_CHAIN_ID = 'reef:${Constants.REEF_MAINNET_GENESIS_HASH.substring(2, 34)}';
String TESTNET_CHAIN_ID = 'reef:${Constants.REEF_TESTNET_GENESIS_HASH.substring(2, 34)}';




class WalletConnectService {
  ReownWalletKit? _web3Wallet;

  final ValueNotifier<List<SessionData>> sessions =
  ValueNotifier<List<SessionData>>([]);

  // Guard to avoid re-disconnecting the same topic concurrently
  final Set<String> _disconnectingTopics = <String>{};

  WalletConnectService() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    _web3Wallet = ReownWalletKit(
      core: ReownCore(projectId: PROJECT_ID),
      metadata: const PairingMetadata(
        name: 'Reef Mobile App',
        description: 'Use Reef chain on mobile phone',
        url: 'https://reef.io/',
        icons: ['https://reef.io/favicons/apple-touch-icon.png'],
      ),
    );

    // Listeners
    _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);
    _web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
    _web3Wallet!.onSessionDelete.subscribe(_onSessionDelete);
    _web3Wallet!.onSessionExpire.subscribe(_onSessionExpire);

    await _web3Wallet!.init();

    // Seed sessions (also dedup just in case)
    final initial = _web3Wallet!.sessions.getAll();
    final dedup = _dedupSessionsImmutable(initial);
    sessions.value = dedup.keep;

    // disconnect duplicates after updating state
    _disconnectTopicsLater(dedup.toDisconnect);
  }

  // ========= SAFE DEDUP =========
  // Returns the final list to keep and the topics to disconnect later
  _DedupResult _dedupSessionsImmutable(List<SessionData> all) {
    debugPrint("wallet connect sessions count: ${all.length}");

    // We keep the MOST RECENT session per URL (iterate from end)
    final Set<String> seenUrls = <String>{};
    final List<SessionData> keepReversed = <SessionData>[];
    final List<String> toDisconnect = <String>[];

    for (int i = all.length - 1; i >= 0; i--) {
      final s = all[i];
      final url = s.peer.metadata.url;
      if (seenUrls.contains(url)) {
        // duplicate -> mark for disconnect
        toDisconnect.add(s.topic);
      } else {
        seenUrls.add(url);
        keepReversed.add(s);
      }
    }

    final keep = keepReversed.reversed.toList();
    debugPrint("wallet connect sessions count post processing: ${keep.length}");
    return _DedupResult(keep: keep, toDisconnect: toDisconnect);
  }

  // Fire-and-forget disconnects AFTER state updated
  void _disconnectTopicsLater(List<String> topics) {
    if (topics.isEmpty) return;

    // schedule so UI update doesn't wait on network
    unawaited(Future(() async {
      for (final t in topics) {
        if (_disconnectingTopics.contains(t)) continue;
        _disconnectingTopics.add(t);
        try {
          await disconnectSession(t);
        } catch (e, st) {
          debugPrint('WalletConnect: disconnect failed for $t: $e\n$st');
        } finally {
          _disconnectingTopics.remove(t);
        }
      }
    }));
  }

  // ========= LIFECYCLE =========
  FutureOr onDispose() {
    _web3Wallet?.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet?.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet?.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3Wallet?.onSessionRequest.unsubscribe(_onSessionRequest);
    _web3Wallet?.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3Wallet?.onSessionExpire.unsubscribe(_onSessionExpire);
  }

  ReownWalletKit getWeb3Wallet() => _web3Wallet!;

  // ========= EVENTS =========
  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    showAlertModal("Error", ["Error in session proposal"]);
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    if (args == null) {
      showAlertModal("Error", ["Empty session proposal"]);
      return;
    }

    // … (your existing validations unchanged) …

    // Validate selected address
    String? selectedAddress = ReefAppState.instance.model.accounts.selectedAddress;
    if (selectedAddress == null || selectedAddress == Constants.ZERO_ADDRESS) {
      showAlertModal("Error", ["No account selected"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.USER_REJECTED).toSignError(),
      );
    }

    // Show approval modal
    String proposerName = args.params.proposer.metadata.name;
    String proposerUrl = args.params.proposer.metadata.url;
    String? proposerIcon = args.params.proposer.metadata.icons.isEmpty
        ? null
        : args.params.proposer.metadata.icons.first;

    bool sessionExists = false;
    for (final s in sessions.value) {
      if (s.peer.metadata.url == proposerUrl) {
        sessionExists = true;
        break;
      }
    }

    final approved = await showWalletConnectSessionModal(
      address: selectedAddress,
      name: proposerName,
      url: proposerUrl,
      icon: proposerIcon,
      sessionExists: sessionExists,
    );

    if (approved != true) {
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.USER_REJECTED).toSignError(),
      );
    }

    // Approve session
    final RequiredNamespace requiredNamespace =
        args.params.requiredNamespaces.entries.first.value;

    final selectedChainId =
    ReefAppState.instance.model.network.selectedNetworkName == Network.mainnet.name
        ? MAINNET_CHAIN_ID
        : TESTNET_CHAIN_ID;

    final accounts = requiredNamespace.chains!
        .map((chainId) => '$chainId:$selectedAddress')
        .toList();

    if (accounts.length > 1 && accounts[1] == '$selectedChainId:$selectedAddress') {
      accounts[1] = accounts[0];
      accounts[0] = '$selectedChainId:$selectedAddress';
    }

    final walletNamespaces = {
      'reef': Namespace(
        accounts: accounts,
        methods: supportedMethods,
        events: supportedEvents,
      ),
    };

    _web3Wallet!.approveSession(
      id: args.id,
      namespaces: walletNamespaces,
    );
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args == null) return;

    // Immutable merge + dedup
    final merged = <SessionData>[...sessions.value, args.session];
    final dedup = _dedupSessionsImmutable(merged);

    // Update state first
    sessions.value = dedup.keep;

    // Then disconnect duplicates
    _disconnectTopicsLater(dedup.toDisconnect);
  }

  void _onSessionRequest(SessionRequestEvent? event) async {
    if (_web3Wallet == null || event == null) return;

    if (!AppLifecycleManager().isAppInForeground &&
        await Permission.scheduleExactAlarm.isGranted) {
      NotificationService().showNotification(
        title: 'WalletConnect Request',
        body: 'Approve the transaction using WalletConnect',
      );
    }

    final chainId = event.chainId;
    if (chainId != MAINNET_CHAIN_ID && chainId != TESTNET_CHAIN_ID) return;

    final method = event.method;
    final id = event.id;
    final topic = event.topic;
    final params = event.params;
    dynamic signature;

    if (method == SIGN_TX_METHOD) {
      final address = params["address"];
      final payload = Map<String, dynamic>.from(params["transactionPayload"]);
      signature = await ReefAppState.instance.signingCtrl.signPayload(address, payload);
    } else if (method == SIGN_MSG_METHOD) {
      final address = params["address"];
      final message = params["message"];
      signature = await ReefAppState.instance.signingCtrl.signRaw(address, message);
    } else {
      throw Errors.getSdkError(Errors.UNSUPPORTED_METHODS);
    }

    ReefAppState.instance.navigationCtrl.navigateToWalletConnectSignaturePage();

    if (signature['error'] != null) {
      return _web3Wallet!.respondSessionRequest(
        topic: topic,
        response: const JsonRpcResponse(
          id: 0, // keep your id if needed
          jsonrpc: '2.0',
          error: JsonRpcError(code: 5001, message: Errors.USER_REJECTED_SIGN),
        ),
      );
    }

    return _web3Wallet!.respondSessionRequest(
      topic: topic,
      response: JsonRpcResponse(
        id: id,
        jsonrpc: '2.0',
        result: signature,
      ),
    );
  }

  void _onSessionDelete(SessionDelete? args) {
    if (args == null) return;
    sessions.value = List<SessionData>.from(sessions.value)
      ..removeWhere((s) => s.topic == args.topic);
  }

  void _onSessionExpire(SessionExpire? args) {
    if (args == null) return;
    sessions.value = List<SessionData>.from(sessions.value)
      ..removeWhere((s) => s.topic == args.topic);
  }

  Future<void> disconnectSession(String topic) async {
    await _web3Wallet!.disconnectSession(
      topic: topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED).toSignError(),
    );
  }
}

// Simple result holder
class _DedupResult {
  final List<SessionData> keep;
  final List<String> toDisconnect;
  const _DedupResult({required this.keep, required this.toDisconnect});
}
