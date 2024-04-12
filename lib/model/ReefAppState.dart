import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/ViewModel.dart';
import 'package:reef_mobile_app/model/analytics/firebaseAnalyticsCtrl.dart';
import 'package:reef_mobile_app/model/appConfig/AppConfigCtrl.dart';
import 'package:reef_mobile_app/model/locale/LocaleCtrl.dart';
import 'package:reef_mobile_app/model/metadata/MetadataCtrl.dart';
import 'package:reef_mobile_app/model/navigation/NavigationCtrl.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/model/storage/StorageCtrl.dart';
import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'package:reef_mobile_app/model/swap/SwapCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
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
  late SwapCtrl swapCtrl;
  late MetadataCtrl metadataCtrl;
  late NetworkCtrl networkCtrl;
  late NavigationCtrl navigationCtrl;
  late LocaleCtrl localeCtrl;
  late AppConfigCtrl appConfigCtrl;
  late StorageCtrl storageCtrl;
  late FirebaseAnalyticsCtrl firebaseAnalyticsCtrl;
  StreamController<String> initStatusStream = StreamController<String>();

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService jsApi, StorageService storage) async {
    this.storage = storage;
    this.initStatusStream.add("starting observables...");
    await _initReefObservables(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting network...");
    networkCtrl = NetworkCtrl(storage, jsApi, model.network);
    firebaseAnalyticsCtrl = FirebaseAnalyticsCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting tokens...");
    tokensCtrl = TokenCtrl(jsApi, model.tokens);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting account...");
    accountCtrl = AccountCtrl(jsApi, storage, model.accounts);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting signer...");
    signingCtrl = SigningCtrl(jsApi, storage, model.signatureRequests, model.accounts);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting transfers...");
    transferCtrl = TransferCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting swap...");
    swapCtrl = SwapCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting metadata...");
    metadataCtrl = MetadataCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting navigation...");
    navigationCtrl =
        NavigationCtrl(model.navigationModel, model.homeNavigationModel);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting state...");
    Network currentNetwork =
        await storage.getValue(StorageKey.network.name) == Network.mainnet.name
            ? Network.mainnet
            : Network.testnet;
    try {
      await _initReefState(jsApi, currentNetwork);
    } catch (e){
      this.initStatusStream.add("error state= ${e.toString()}");
    }
    this.initStatusStream.add("starting config...");
    appConfigCtrl = AppConfigCtrl(storage, model.appConfig);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting locale...");
    localeCtrl = LocaleCtrl(storage, model.locale);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("starting storage...");
    storageCtrl = StorageCtrl(storage);
    await Future.delayed(Duration(milliseconds: 200));
    this.initStatusStream.add("complete");
  }

  _initReefState(JsApiService jsApiService, Network currentNetwork) async {
    var accounts = await accountCtrl.getStorageAccountsList();
    await jsApiService.jsPromise(
        'window.jsApi.initReefState("${currentNetwork.name}", ${jsonEncode(accounts)})');
  }

  _initReefObservables(JsApiService reefAppJsApiService) async {
    reefAppJsApiService.jsMessageUnknownSubj.listen((JsApiMessage value) {
      print('jsMSG not handled id=${value.streamId}');
    });
  }
}
