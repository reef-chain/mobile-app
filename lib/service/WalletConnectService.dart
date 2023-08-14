import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:reef_mobile_app/components/modals/alert_modal.dart';
import 'package:reef_mobile_app/components/modals/wallet_connect_session_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

// TODO: get this with `String.fromEnvironment('WALLET_CONNECT_PROJECT_ID')`
const String PROJECT_ID = 'b20768c469f63321e52923a168155240';
const String MAINNET_CHAIN_ID = 'reef:7834781d38e4798d548e34ec947d19de';
const String TESTNET_CHAIN_ID = 'reef:b414a8602b2251fa538d38a932239150';
const String SIGN_TX_METHOD = 'reef_signTransaction';
const String SIGN_MSG_METHOD = 'reef_signMessage';
const List<String> supportedMethods = [SIGN_TX_METHOD, SIGN_MSG_METHOD];
const List<String> supportedEvents = []; // Events not supported for now

class WalletConnectService {
  Web3Wallet? _web3Wallet;

  ValueNotifier<List<PairingInfo>> pairings =
      ValueNotifier<List<PairingInfo>>([]);
  ValueNotifier<List<SessionData>> sessions =
      ValueNotifier<List<SessionData>>([]);
  ValueNotifier<List<StoredCacao>> auth = ValueNotifier<List<StoredCacao>>([]);

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
    _web3Wallet!.core.pairing.onPairingInvalid.subscribe(_onPairingInvalid);
    _web3Wallet!.core.pairing.onPairingCreate.subscribe(_onPairingCreate);
    _web3Wallet!.pairings.onSync.subscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposal.subscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.subscribe(_onSessionProposalError);
    _web3Wallet!.onSessionConnect.subscribe(_onSessionConnect);

    // Await the initialization of the web3wallet
    print('web3wallet init');
    await _web3Wallet!.init();

    pairings.value = _web3Wallet!.pairings.getAll();
    sessions.value = _web3Wallet!.sessions.getAll();
    auth.value = _web3Wallet!.completeRequests.getAll();

    // Register method handlers
    _web3Wallet!.registerRequestHandler(
      chainId: MAINNET_CHAIN_ID,
      method: SIGN_TX_METHOD,
      handler: signTxRequestHandler,
    );
    _web3Wallet!.registerRequestHandler(
      chainId: TESTNET_CHAIN_ID,
      method: SIGN_TX_METHOD,
      handler: signTxRequestHandler,
    );
    _web3Wallet!.registerRequestHandler(
      chainId: MAINNET_CHAIN_ID,
      method: SIGN_MSG_METHOD,
      handler: signMessageRequestHandler,
    );
    _web3Wallet!.registerRequestHandler(
      chainId: TESTNET_CHAIN_ID,
      method: SIGN_MSG_METHOD,
      handler: signMessageRequestHandler,
    );
  }

  FutureOr onDispose() {
    print('web3wallet dispose');
    _web3Wallet!.core.pairing.onPairingInvalid.unsubscribe(_onPairingInvalid);
    _web3Wallet!.pairings.onSync.unsubscribe(_onPairingsSync);
    _web3Wallet!.onSessionProposal.unsubscribe(_onSessionProposal);
    _web3Wallet!.onSessionProposalError.unsubscribe(_onSessionProposalError);
    _web3Wallet!.onSessionConnect.unsubscribe(_onSessionConnect);
  }

  Web3Wallet getWeb3Wallet() {
    return _web3Wallet!;
  }

  void _onPairingsSync(StoreSyncEvent? args) {
    if (args != null) {
      pairings.value = _web3Wallet!.pairings.getAll();
    }
  }

  void _onSessionProposalError(SessionProposalErrorEvent? args) {
    print(args);
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
    if (selectedAddress == null) {
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
      final walletNamespaces = {
        'reef': Namespace(
          accounts: [
            '$MAINNET_CHAIN_ID:$selectedAddress',
            '$TESTNET_CHAIN_ID:$selectedAddress'
          ],
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

  void _onPairingInvalid(PairingInvalidEvent? args) {
    print('Pairing Invalid Event: $args');
  }

  void _onPairingCreate(PairingEvent? args) {
    print('Pairing Create Event: $args');
  }

  void _onSessionConnect(SessionConnect? args) {
    if (args != null) {
      print(args);
      sessions.value.add(args.session);
    }
  }

  Future<void> disconnectSession(String pairingTopic) async {
    await _web3Wallet!.disconnectSession(
      topic: pairingTopic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
  }

  Future<dynamic> signTxRequestHandler(String topic, dynamic parameters) async {
    String address = parameters["address"];
    Map<String, dynamic> payload = parameters["transactionPayload"];

    var signature;
    try {
      signature = await ReefAppState.instance.signingCtrl.signPayload(address, payload);
      // TODO: Catch rejection from user
    } catch (e) {
      print('Error signing transaction: $e');
      throw Errors.getSdkError(Errors.USER_REJECTED_SIGN);
    }
    return signature;
  }

  Future<dynamic> signMessageRequestHandler(String topic, dynamic parameters) async {
    String address = parameters["address"];
    String message = parameters["message"];

    var signature = await ReefAppState.instance.signingCtrl.signRaw(address, message).catchError((err){
        print('Error signing transaction: $err');
        throw Errors.getSdkError(Errors.USER_REJECTED_SIGN);
      });
      print('WC sig=$signature');
     return signature;
  }
}
