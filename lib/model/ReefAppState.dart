import 'dart:convert';

import 'package:reef_mobile_app/model/ViewModel.dart';
import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
import 'package:reef_mobile_app/model/tokens/token_model.dart';
import 'package:reef_mobile_app/model/transfer/TransferCtrl.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

import 'account/AccountCtrl.dart';

class ReefAppState {
  static ReefAppState? _instance;

  final ViewModel model = ViewModel();

  late StorageService storage;
  late TokenCtrl tokensCtrl;
  late AccountCtrl accountCtrl;
  late SigningCtrl signingCtrl;
  late TransferCtrl transferCtrl;
  late TokenModel tokenModel;

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService jsApi, StorageService storage) async {
    this.storage = storage;
    await _initReefState(jsApi);
    await _initReefObservables(jsApi);
    tokensCtrl = TokenCtrl(jsApi, model.tokens);
    accountCtrl = AccountCtrl(jsApi, storage, model.accounts);
    signingCtrl = SigningCtrl(jsApi, storage, model.signatureRequests);
    transferCtrl = TransferCtrl(jsApi);
  }

  _initReefState(JsApiService jsApiService) async {
    var accounts = [];
    (await storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));

    await jsApiService
        .jsPromise('jsApi.initReefState("testnet", ${jsonEncode(accounts)})');
  }

  _initReefObservables(JsApiService reefAppJsApiService) async {
    reefAppJsApiService.jsMessageUnknownSubj.listen((JsApiMessage value) {
      print('jsMSG not handled id=${value.streamId}');
    });
  }
}