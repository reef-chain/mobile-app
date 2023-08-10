import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

String MAINNET_CHAIN_ID = 'reef:7834781d38e4798d548e34ec947d19de';
String TESTNET_CHAIN_ID = 'reef:b414a8602b2251fa538d38a932239150';
String SIGN_TX_METHOD = 'reef_signTransaction';
String SIGN_MSG_METHOD = 'reef_signMessage';
List<String> supportedMethods = [SIGN_TX_METHOD, SIGN_MSG_METHOD];
List<String> supportedEvents = []; // Empty for now

String getChainId() {
  return ReefAppState.instance.model.network.selectedNetworkName ==
          Network.mainnet.name
      ? MAINNET_CHAIN_ID
      : TESTNET_CHAIN_ID;
}

class WalletConnectPage extends StatefulWidget {
  final String uriString;

  const WalletConnectPage(this.uriString, {Key? key}) : super(key: key);

  @override
  State<WalletConnectPage> createState() => _WalletConnectPage();
}

class _WalletConnectPage extends State<WalletConnectPage> {
  late Web3Wallet web3Wallet;
  int? currentSessionId;
  late PairingInfo pairing;

  @override
  void initState() {
    super.initState();
    initWalletConnect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // About flow: https://github.com/WalletConnect/WalletConnectFlutterV2/issues/66
  // TODO auth request support?
  Future<void> initWalletConnect() async {
    try {
      web3Wallet = await Web3Wallet.createInstance(
        relayUrl: 'wss://relay.walletconnect.com',
        projectId:
            'b20768c469f63321e52923a168155240', // TODO: Is is safe to expose this?
        metadata: const PairingMetadata(
          name: 'Reef Mobile App',
          description: 'Use Reef chain on mobile phone',
          url: 'https://reef.io/',
          icons: ['https://reef.io/favicons/apple-touch-icon.png'],
        ),
      );

      web3Wallet.onSessionProposal
          .subscribe((SessionProposalEvent? sessionProposal) async {
        // TODO messages
        if (sessionProposal == null) return;
        currentSessionId = sessionProposal.id;

        if (sessionProposal.params.requiredNamespaces.entries.isEmpty) {
          return rejectConnection(Errors.INVALID_SESSION_SETTLE_REQUEST);
        }

        if (sessionProposal.params.requiredNamespaces.entries.length > 1 ||
            sessionProposal.params.requiredNamespaces.entries.first.key !=
                'reef') {
          return rejectConnection(Errors.UNSUPPORTED_NAMESPACE_KEY);
        }

        RequiredNamespace requiredNamespace =
            sessionProposal.params.requiredNamespaces.entries.first.value;
        if (requiredNamespace.chains == null ||
            requiredNamespace.chains!.isEmpty ||
            !requiredNamespace.chains!.every((chain) =>
                chain == MAINNET_CHAIN_ID || chain == TESTNET_CHAIN_ID)) {
          return rejectConnection(Errors.UNSUPPORTED_CHAINS);
        }
        // TODO: Check if chain is supported and is current network
        // TODO: store allowed chains?
        if (requiredNamespace.methods.isEmpty ||
            !requiredNamespace.methods
                .every((method) => supportedMethods.contains(method))) {
          return rejectConnection(Errors.UNSUPPORTED_METHODS);
        }
        // TODO: store allowed methods?
        if (requiredNamespace.events.isNotEmpty &&
            !requiredNamespace.events
                .every((event) => supportedEvents.contains(event))) {
          return rejectConnection(Errors.UNSUPPORTED_EVENTS);
        }
        // TODO: store allowed events?

        String proposerName = sessionProposal.params.proposer.metadata.name;
        String proposerUrl = sessionProposal.params.proposer.metadata.url;
      });

      web3Wallet.registerRequestHandler(
        chainId: getChainId(),
        method: SIGN_TX_METHOD,
        handler: signTxRequestHandler,
      );

      web3Wallet.registerRequestHandler(
        chainId: getChainId(),
        method: SIGN_MSG_METHOD,
        handler: signMessageRequestHandler,
      );

      String uriString = 
      "wc:c6127535ecd993280e40da439343c6c09f127bec58ac155e25f56bebace006f4@2?relay-protocol=irn&symKey=1f1e3271534a4e913c06742a9599cd48c92353feedab28ebc88fca3731a590ed";
      Uri uri = Uri.parse(uriString); // TODO: use widget.uriString
      pairing = await web3Wallet.pair(uri: uri);
    } catch (e) {
      print('Error initializing WalletConnect: $e');
    }
  }

  Future<dynamic> signMessageRequestHandler(String topic, dynamic parameters) async {
    String address = parameters["address"];
    String message = parameters["message"];

    var signature;
    try {
      signature = await ReefAppState.instance.signingCtrl.signRaw(address, message);
      // TODO: Catch rejection from user
    } catch (e) {
      print('Error signing transaction: $e');
      throw Errors.getSdkError(Errors.USER_REJECTED_SIGN);
    }
    return signature;
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

  Future<void> handleApproval(approve) async {
    // Present the UI to the user, and allow them to reject or approve the proposal
    if (approve) {
      String address = ReefAppState.instance.model.accounts.selectedAddress!;
      final walletNamespaces = {
        'reef': Namespace(
          accounts: [
            '$MAINNET_CHAIN_ID:$address',
            '$TESTNET_CHAIN_ID:$address'
          ], // TODO: set approved accounts
          methods: supportedMethods,
          events: supportedEvents,
        )
      };

      await web3Wallet.approveSession(
          id: currentSessionId!,
          namespaces:
              walletNamespaces // This will have the accounts requested in params
          );
    } else {
      await rejectConnection(Errors.USER_REJECTED);
    }
  }

  Future<void> rejectConnection(String errorCode) async {
    await web3Wallet.rejectSession(
      id: currentSessionId!,
      reason: Errors.getSdkError(errorCode),
    );
  }

  Future<void> handleDisconnect() async {
    await web3Wallet.disconnectSession(
      topic: pairing.topic,
      reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'WalletConnect Session ID: ${currentSessionId ?? 'Not connected'}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await handleApproval(true);
            },
            child: Text('Connect'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await handleApproval(false);
            },
            child: Text('Reject'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await handleApproval(false);
            },
            child: Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}
