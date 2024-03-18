import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/ViewModel.dart';
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
  StreamController<String> initStatusStream = StreamController<String>();

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService jsApi, StorageService storage) async {
    this.storage = storage;
    this.initStatusStream.add("Starting observables...");
    await _initReefObservables(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting network...");
    networkCtrl = NetworkCtrl(storage, jsApi, model.network);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting tokens...");
    tokensCtrl = TokenCtrl(jsApi, model.tokens);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting account...");
    accountCtrl = AccountCtrl(jsApi, storage, model.accounts);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting signer...");
    signingCtrl = SigningCtrl(jsApi, storage, model.signatureRequests, model.accounts);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting transfers...");
    transferCtrl = TransferCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting swap...");
    swapCtrl = SwapCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting metadata...");
    metadataCtrl = MetadataCtrl(jsApi);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting navigation...");
    navigationCtrl =
        NavigationCtrl(model.navigationModel, model.homeNavigationModel);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting state...");
    Network currentNetwork =
        await storage.getValue(StorageKey.network.name) == Network.testnet.name
            ? Network.testnet
            : Network.mainnet;
    try {
      await _initReefState(jsApi, currentNetwork);
    } catch (e){
      this.initStatusStream.add("Error state= ${e.toString()}");
    }
    this.initStatusStream.add("Starting config...");
    appConfigCtrl = AppConfigCtrl(storage, model.appConfig);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting locale...");
    localeCtrl = LocaleCtrl(storage, model.locale);
    await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("Starting storage...");
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
