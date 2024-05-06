import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/components/modals/wallet_connect_session_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

const String PROJECT_ID = 'b20768c469f63321e52923a168155240';
const String SIGN_TX_METHOD = 'reef_signTransaction';
const String SIGN_MSG_METHOD = 'reef_signMessage';
const List<String> supportedMethods = [SIGN_TX_METHOD, SIGN_MSG_METHOD];
const List<String> supportedEvents = []; // Events not supported for now
String MAINNET_CHAIN_ID = 'reef:${Constants.REEF_MAINNET_GENESIS_HASH.substring(2, 34)}';
String TESTNET_CHAIN_ID = 'reef:${Constants.REEF_TESTNET_GENESIS_HASH.substring(2, 34)}';

class WalletConnectService {
  Web3Wallet? _web3Wallet;

  ValueNotifier<List<SessionData>> sessions =
      ValueNotifier<List<SessionData>>([]);

  WalletConnectService() {
    _initAsync();
  }

  Future<void> _initAsync() async {
    // Create the web3wallet
    _web3Wallet = Web3Wallet(
      core: Core(
        projectId: PROJECT_ID,
      ),
      metadata: const PairingMetadata(
        name: 'Reef Mobile App',
          description: 'Use Reef chain on mobile phone',
          url: 'https://reef.io/',
          icons: ['https://reef.io/favicons/apple-touch-icon.png'],
      ),
    );

    // Setup listeners
    print('web3wallet create');
    // _web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    // _web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    // _web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);
    _web3Wallet!.onSessionRequest.subscribe(_onSessionRequest);
    _web3Wallet!.onSessionDelete.subscribe(_onSessionDelete);
    _web3Wallet!.onSessionExpire.subscribe(_onSessionExpire);

    // Await the initialization of the web3wallet
    print('web3wallet init');
    await _web3Wallet!.init();

    sessions.value = _web3Wallet!.sessions.getAll();
  }

  FutureOr onDispose() {
    print('web3wallet dispose');
    // _web3Wallet!.core.pairing.onPairingCreate.unsubscribe(_onPairingCreate);
    // _web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    // _web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet!.onSessionConnect.unsubscribe(_onSessionConnect);
    _web3Wallet!.onSessionRequest.unsubscribe(_onSessionRequest);
    _web3Wallet!.onSessionDelete.unsubscribe(_onSessionDelete);
    _web3Wallet!.onSessionExpire.unsubscribe(_onSessionExpire);
  }

  Web3Wallet getWeb3Wallet() {
    return _web3Wallet!;
  }

  // void _onPairingCreate(PairingEvent? args) {
  //   print('Pairing Create Event: $args');
  // }

  // void _onPairingInvalid(PairingInvalidEvent? args) {
  //   print('Pairing Invalid Event: $args');
  // }

  // void _onPairingsSync(StoreSyncEvent? args) {
  //   print('Pairings Sync Event: $args');
  // }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    showAlertModal("Error", ["Error in session proposal"]);
  }

  void _onSessionProposal(SessionProposalEvent? args) async {
    if (args == null) {
      showAlertModal("Error", ["Empty session proposal"]);
      return;
    }

    // Namespace validations
    if (args.params.requiredNamespaces.entries.isEmpty) {
      showAlertModal("Error", ["Invalid namespaces in session proposal"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.USER_REJECTED)
      );
    }
    if (args.params.requiredNamespaces.entries.length > 1 ||
        args.params.requiredNamespaces.entries.first.key != 'reef') {
      showAlertModal("Error", ["Invalid namespaces in session proposal"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.UNSUPPORTED_NAMESPACE_KEY)
      );
    }
    // Chains validations
    RequiredNamespace requiredNamespace = args.params.requiredNamespaces.entries.first.value;
    if (requiredNamespace.chains == null || requiredNamespace.chains!.isEmpty ||
        !requiredNamespace.chains!.every((chain) => chain == MAINNET_CHAIN_ID ||
        chain == TESTNET_CHAIN_ID)
    ) {
      showAlertModal("Error", ["Invalid chain IDs in session proposal"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.UNSUPPORTED_CHAINS)
      );
    }
    // Methods validations
    if (requiredNamespace.methods.isEmpty ||
        !requiredNamespace.methods.every((method) => supportedMethods.contains(method))
    ) {
      showAlertModal("Error", ["Unsupported methods in session proposal"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.UNSUPPORTED_METHODS)
      );
    }
    // Events validations
    if (requiredNamespace.events.isNotEmpty &&
        !requiredNamespace.events.every((event) => supportedEvents.contains(event))
    ) {
      showAlertModal("Error", ["Unsupported events in session proposal"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.UNSUPPORTED_EVENTS)
      );
    }

    // Validate selected address
    String? selectedAddress = ReefAppState.instance.model.accounts.selectedAddress;
    if (selectedAddress == null || selectedAddress == Constants.ZERO_ADDRESS) {
      showAlertModal("Error", ["No account selected"]);
      return _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.USER_REJECTED)
      );
    }

    // Show approval modal
    String proposerName = args.params.proposer.metadata.name;
    String proposerUrl = args.params.proposer.metadata.url;
    String? proposerIcon = args.params.proposer.metadata.icons.isEmpty
      ? null : args.params.proposer.metadata.icons.first;
    final approved = await showWalletConnectSessionModal(
      address: selectedAddress, name: proposerName, url: proposerUrl, icon: proposerIcon);

    // Handle user response
    if (approved != null && approved) {
      // Map chains to approved chainId
      var selectedChainId = ReefAppState.instance.model.network.selectedNetworkName == Network.mainnet.name 
        ? MAINNET_CHAIN_ID : TESTNET_CHAIN_ID;
      var accounts = requiredNamespace.chains!.map((chainId) => '$chainId:$selectedAddress').toList();
      // Pass in first position account with chainId of the selected network, as a convention
      if (accounts.length > 1 && accounts[1] == '$selectedChainId:$selectedAddress') {
        accounts[1] = accounts[0];
        accounts[0] = '$selectedChainId:$selectedAddress';
      }
      final walletNamespaces = {
        'reef': Namespace(
          accounts: accounts,
          methods: supportedMethods,
          events: supportedEvents,
        )
      };

      _web3Wallet!.approveSession(
        id: args.id,
        namespaces: walletNamespaces,
      );
    } else {
      _web3Wallet!.rejectSession(
        id: args.id,
        reason: Errors.getSdkError(Errors.USER_REJECTED)
      );
    }
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      sessions.value = List.from(sessions.value)
        ..add(args.session);
    }
  }

  void _onSessionRequest(SessionRequestEvent? event) async {
    if (_web3Wallet == null) return;
    if (event == null) return;

    final chainId = event.chainId;
    if (chainId != MAINNET_CHAIN_ID && chainId != TESTNET_CHAIN_ID) return;

    final method = event.method;
    final id = event.id;
    final topic = event.topic;
    final params = event.params;
    dynamic signature;

    if (method == SIGN_TX_METHOD) {
      String address = params["address"];
      Map<String, dynamic> payload = params["transactionPayload"];
      signature = await ReefAppState.instance.signingCtrl.signPayload(address, payload);
    } else if (event.method == SIGN_MSG_METHOD) {
      String address = params["address"];
      String message = params["message"];
      signature = await ReefAppState.instance.signingCtrl.signRaw(address, message);
    } else {
      throw Errors.getSdkError(Errors.UNSUPPORTED_METHODS);
    }

    if (signature['error'] != null) {
      return _web3Wallet!.respondSessionRequest(
        topic: topic,
        response: JsonRpcResponse(
          id: id,
          jsonrpc: '2.0',
          error: const JsonRpcError(code: 5001, message: Errors.USER_REJECTED_SIGN),
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
    if (args != null) {
      sessions.value = List.from(sessions.value)
        ..removeWhere((session) => session.topic == args.topic);
    }
  }

  void _onSessionExpire(SessionExpire? args) {
    if (args != null) {
      sessions.value = List.from(sessions.value)
        ..removeWhere((session) => session.topic == args.topic);
    }
  }

  Future<void> disconnectSession(String topic) async {
    await _web3Wallet!.disconnectSession(
      topic: topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
  }
}
