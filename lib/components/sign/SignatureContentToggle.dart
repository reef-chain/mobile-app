import 'dart:async';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/sign/MethodBytesDataDisplay.dart';
import 'package:reef_mobile_app/components/sign/SignatureControls.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_json.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/service/TransactionDescService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import '../../utils/functions.dart';
import 'MethodDataDisplay.dart';
import 'MethodDataLoadingIndicator.dart';
import 'package:mobx/mobx.dart';


class SignatureContentToggle extends StatefulWidget {
  final Widget content;

  const SignatureContentToggle(this.content, {Key? key}) : super(key: key);

  @override
  State<SignatureContentToggle> createState() => _SignatureContentToggleState();
}

class _SignatureContentToggleState extends State<SignatureContentToggle> {
  ReactionDisposer? _disposer;

  SignatureRequest? _signatureRequest;
  StatusDataObject<ReefAccount>? _signer;

  @override
  void initState() {
    super.initState();

    // React to changes in the signature request list and update UI state
    _disposer = reaction<List<SignatureRequest>>(
          (_) => ReefAppState.instance.model.signatureRequests.list,
          (requests) {
        if (!mounted) return;
        final req = requests.isNotEmpty ? requests.first : null;

        StatusDataObject<ReefAccount>? signer;
        if (req != null) {
          try {
            signer = ReefAppState.instance.signingCtrl.getSignatureSigner(req);
          } catch (_) {
            signer = null;
          }
        }

        setState(() {
          _signatureRequest = req;
          _signer = signer;
        });
      },
      delay: 0, // no debounce; update immediately
    );

    // Seed current state once
    final current = ReefAppState.instance.model.signatureRequests.list;
    if (current.isNotEmpty) {
      final req = current.first;
      StatusDataObject<ReefAccount>? signer;
      try {
        signer = ReefAppState.instance.signingCtrl.getSignatureSigner(req);
      } catch (_) {
        signer = null;
      }
      _signatureRequest = req;
      _signer = signer;
    }
  }

  @override
  void dispose() {
    _disposer?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayIdx = _signatureRequest != null ? 0 : 1;
    return IndexedStack(
      index: displayIdx,
      children: [
        buildSignUI(context, _signatureRequest, _signer),
        widget.content,
      ],
    );
  }

  Scaffold buildSignUI(
      BuildContext context,
      SignatureRequest? signatureRequest,
      StatusDataObject<ReefAccount>? account,
      ) {
    return Scaffold(
      backgroundColor: Styles.primaryBackgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            AppLocalizations.of(context)!.sign_transaction,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Styles.textColor,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: Image.asset('assets/images/reef.png'),
        ),
        backgroundColor: Styles.primaryBackgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text('Signing with account:'),
          if (account != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AccountBox(
                    reefAccountFDM: account,
                    selected: false,
                    onSelected: () {},
                    showOptions: false,
                    lightTheme: true,
                  ),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                const Gap(48),
                if (signatureRequest?.payload is SignerPayloadJSON)
                  Text(
                    "Transaction on ${isMainnet(signatureRequest?.payload.genesisHash) ? 'Reef Mainnet' : toShortDisplay(signatureRequest?.payload.genesisHash?.toString())}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                const Gap(24),
                FutureBuilder<String?>(
                  future: TransactionDescService.getTransactionDesc(
                      context, signatureRequest),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const Gap(15),
                MethodDataLoadingIndicator(signatureRequest),
                signatureRequest?.payload.type == "bytes"
                    ? MethodBytesDataDisplay(
                    signatureRequest, signatureRequest?.bytesData)
                    : MethodDataDisplay(signatureRequest),
              ],
            ),
          ),
          if (signatureRequest != null)
            Column(
              children: [
                SignatureControls(
                  signatureRequest,
                      (String? password) =>
                      _confirmSign(signatureRequest, password),
                      () => _cancel(signatureRequest),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmSign(
      SignatureRequest signatureRequest,
      String? password,
      ) {
    return ReefAppState.instance.signingCtrl
        .authenticateAndSign(signatureRequest, password);
  }

  void _cancel(SignatureRequest? signatureRequest) {
    if (signatureRequest == null) return;
    ReefAppState.instance.signingCtrl
        .rejectSignature(signatureRequest.signatureIdent);
  }
}
