import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobx/mobx.dart' show Store;
import 'package:reef_chain_flutter/js_api_service.dart';

import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_json.dart';
import 'package:reef_mobile_app/model/signing/signer_payload_raw.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/account/account_model.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';



class SigningCtrl {
  // Known error markers for UI mapping
  static const String SIGN_ERR_CANCELED = "_canceled";
  static const String SIGN_ERR_EMPTY_MNEMONIC = "_empty-mnemonic-value";
  static const String SIGN_ERR_TIMEOUT = "timeout";
  static const String SIGN_ERR_PROVIDER_DISCONNECTED = "provider_disconnected";
  static const String SIGN_ERR_SIGNER_NOT_FOUND = "signer_not_found";

  final SignatureRequests signatureRequests;
  final StorageService storage;
  final AccountModel accountModel;
  final ReefChainApi reefChainApi;
  static final LocalAuthentication localAuth = LocalAuthentication();

  StreamSubscription? _jsSigSub;

  SigningCtrl(
      this.storage,
      this.signatureRequests,
      this.accountModel,
      this.reefChainApi,
      ) {
    _jsSigSub = reefChainApi.reefState.signingApi
        .jsTxSignatureConfirmationMessageSubj
        .listen(
          (jsApiMessage) {
        try {
          final signatureRequest = _buildSignatureRequest(jsApiMessage);
          if (signatureRequest.payload is SignerPayloadJSON) {
            signatureRequest.decodeMethod();
          }
          signatureRequests.add(signatureRequest);
        } catch (e, st) {
          debugPrint('SigningCtrl: failed to build/add SignatureRequest: $e\n$st');
        }
      },
      onError: (e, st) {
        debugPrint('SigningCtrl stream error: $e\n$st');
      },
      cancelOnError: false,
    );
  }

  void dispose() {
    _jsSigSub?.cancel();
  }

  /// Public API kept for compatibility (SignatureContentToggle calls this).
  /// Returns the signer as a StatusDataObject<ReefAccount>.
  StatusDataObject<ReefAccount> getSignatureSigner(SignatureRequest signatureReq) {
    final signer = accountModel.accountsFDM.data.firstWhere(
          (acc) => acc.data.address == signatureReq.payload.address,
      orElse: () => throw Exception(SIGN_ERR_SIGNER_NOT_FOUND),
    );
    return signer;
  }

  /// Internal guard: throws if signer doesn't exist.
  void _ensureSignerExists(SignatureRequest signatureReq) {
    // Will throw if not found
    getSignatureSigner(signatureReq);
  }

  /// Auth + confirm signature with robust error handling.
  /// Returns `true` only if the signature was confirmed successfully.
  Future<bool> authenticateAndSign(
      SignatureRequest signatureRequest,
      String? verifyPassword,
      ) async {
    bool authenticated = false;

    try {
      // Choose auth method
      if (await checkBiometricsSupport() &&
          (verifyPassword == null || verifyPassword.isEmpty)) {
        authenticated = await _authenticateWithBiometrics(signatureRequest);
      } else {
        authenticated = await _authenticateWithPassword(signatureRequest, verifyPassword);
      }

      if (authenticated != true) {
        _safeReject(signatureRequest.signatureIdent, reason: SIGN_ERR_CANCELED);
        return false;
      }

      // Confirm signature (may throw)
      await _confirmSignature(
        signatureRequest.signatureIdent,
        signatureRequest.payload.address,
      );

      return true;
    } on TimeoutException {
      _safeReject(signatureRequest.signatureIdent, reason: SIGN_ERR_TIMEOUT);
      return false;
    } catch (e, st) {
      debugPrint('authenticateAndSign error: $e\n$st');
      final reason = e.toString().contains('signer_not_found')
          ? SIGN_ERR_SIGNER_NOT_FOUND
          : (e.toString().contains('provider') ? SIGN_ERR_PROVIDER_DISCONNECTED : SIGN_ERR_CANCELED);
      _safeReject(signatureRequest.signatureIdent, reason: reason);
      return false;
    }
  }

  Future<dynamic> signRaw(String address, String message) async {
    try {
      return await reefChainApi.reefState.signingApi.signRaw(address, message);
    } catch (e, st) {
      debugPrint('signRaw error: $e\n$st');
      return {'success': false, 'data': SIGN_ERR_CANCELED};
    }
  }

  Future<dynamic> signPayload(String address, Map<String, dynamic> payload) async {
    try {
      return await reefChainApi.reefState.signingApi.signPayload(address, payload);
    } catch (e, st) {
      debugPrint('signPayload error: $e\n$st');
      return {'success': false, 'data': SIGN_ERR_CANCELED};
    }
  }

  Future<dynamic> decodeMethod(String data, {dynamic types}) async {
    try {
      return types == null
          ? await reefChainApi.reefState.signingApi.decodeMethod(data)
          : await reefChainApi.reefState.signingApi.decodeMethod(
        data,
        types: jsonEncode(types),
      );
    } catch (e, st) {
      debugPrint('decodeMethod error: $e\n$st');
      rethrow;
    }
  }

  Future<dynamic> bytesString(String bytes) =>
      reefChainApi.reefState.signingApi.bytesString(bytes);

  /// Confirms the signature. Removes any pending UI entry *before* confirm call.
  /// Throws on errors so caller can map to UI.
  Future<void> _confirmSignature(String sigConfirmationIdent, String address) async {
    final account = await storage.getAccount(address);
    if (account == null) {
      signatureRequests.remove(sigConfirmationIdent);
      throw Exception(SIGN_ERR_SIGNER_NOT_FOUND);
    }

    if (account.mnemonic == null || (account.mnemonic?.isEmpty ?? true)) {
      signatureRequests.remove(sigConfirmationIdent);
      throw Exception(SIGN_ERR_EMPTY_MNEMONIC);
    }

    // Always remove pending signature entry before proceeding
    signatureRequests.remove(sigConfirmationIdent);

    try {
      // Just await — DO NOT “return” or use its result
       reefChainApi.reefState.signingApi
          .confirmTxSignature(sigConfirmationIdent, account.mnemonic);
    } catch (e, st) {
      debugPrint('confirmTxSignature error: $e\n$st');
      rethrow;
    }
  }

  Future<dynamic> sendNFT(
      String unresolvedFrom,
      String nftContractAddress,
      String from,
      String to,
      int nftAmount,
      int nftId,
      ) async {
    try {
      return await reefChainApi.reefState.signingApi
          .sendNFT(unresolvedFrom, nftContractAddress, from, to, nftAmount, nftId);
    } catch (e, st) {
      debugPrint('sendNFT error: $e\n$st');
      return {'success': false, 'data': SIGN_ERR_CANCELED};
    }
  }

  Future<dynamic> getTypes(String genesisHash, String specVersion) async {
    dynamic types;
    final metadata = await storage.getMetadata(genesisHash);
    if (metadata != null &&
        metadata.specVersion == int.parse(specVersion.substring(2), radix: 16)) {
      types = metadata.types;
    }
    return types;
  }

  SignatureRequest _buildSignatureRequest(JsApiMessage jsApiMessage) {
    final signatureIdent = jsApiMessage.reqId;
    late final Store payload;

    if (jsApiMessage.value["data"] != null) {
      payload = SignerPayloadRaw(
        jsApiMessage.value["address"],
        jsApiMessage.value["data"],
        jsApiMessage.value["type"],
      );
    } else {
      payload = SignerPayloadJSON(
        jsApiMessage.value["address"],
        jsApiMessage.value["blockHash"],
        jsApiMessage.value["blockNumber"],
        jsApiMessage.value["era"],
        jsApiMessage.value["genesisHash"],
        jsApiMessage.value["method"],
        jsApiMessage.value["nonce"],
        jsApiMessage.value["specVersion"],
        jsApiMessage.value["tip"],
        jsApiMessage.value["transactionVersion"],
        jsApiMessage.value["signedExtensions"].cast<String>(),
        jsApiMessage.value["version"],
      );
    }

    return SignatureRequest(signatureIdent, payload, this);
  }

  void rejectSignature(String signatureIdent) {
    try {
      signatureRequests.remove(signatureIdent);
      reefChainApi.reefState.signingApi.rejectTxSignature(signatureIdent);
    } catch (e, st) {
      debugPrint('rejectSignature error: $e\n$st');
    }
  }

  Future<bool> checkBiometricsSupport() async {
    try {
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final isAvailable = await localAuth.canCheckBiometrics;
      return isAvailable && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _authenticateWithBiometrics(SignatureRequest signatureReq) async {
    try {
      _ensureSignerExists(signatureReq);
      return await localAuth.authenticate(
        localizedReason: 'Authenticate with biometrics',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e, st) {
      debugPrint('biometrics auth error: $e\n$st');
      return false;
    }
  }

  Future<bool> _authenticateWithPassword(SignatureRequest signatureReq, String? value) async {
    try {
      if (value == null || value.isEmpty) return false;
      _ensureSignerExists(signatureReq);

      // TODO: replace with secure hash check (bcrypt/argon2) in secure storage.
      final storedPassword = await storage.getValue(StorageKey.password.name);
      return storedPassword == value;
    } catch (e, st) {
      debugPrint('password auth error: $e\n$st');
      return false;
    }
  }

  /// Backstop rejection that also removes any dangling UI entry
  void _safeReject(String signatureIdent, {String? reason}) {
    try {
      signatureRequests.remove(signatureIdent);
      reefChainApi.reefState.signingApi.rejectTxSignature(signatureIdent);
    } catch (_) {
      // ignore
    }
    if (kDebugMode) {
      debugPrint('Signature rejected: $reason');
    }
  }

  bool isTransaction(SignatureRequest signatureRequest) {
    return signatureRequest.payload.type == "bytes";
  }

  Future<TxDecodedData> getTxDecodedData(dynamic payload, dynamic decodedMethod) async {
    final txDecodedData = TxDecodedData(
      specVersion: hexToDecimalString(payload.specVersion),
      nonce: hexToDecimalString(payload.nonce),
    );

    txDecodedData.genesisHash = payload.genesisHash;
    txDecodedData.methodName = decodedMethod["methodName"];
    const jsonEncoder = JsonEncoder.withIndent("  ");
    txDecodedData.args = jsonEncoder.convert(decodedMethod["args"]);
    txDecodedData.info = decodedMethod["info"];
    txDecodedData.rawMethodData = payload.method;

    if (payload.tip != null) {
      txDecodedData.tip = hexToDecimalString(payload.tip);
    }
    return txDecodedData;
  }
}
