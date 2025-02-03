import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/network/network.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_chain_flutter/reef_state/account/account.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/ViewModel.dart';
import 'package:reef_mobile_app/model/analytics/firebaseAnalyticsCtrl.dart';
import 'package:reef_mobile_app/model/appConfig/AppConfigCtrl.dart';
import 'package:reef_mobile_app/model/locale/LocaleCtrl.dart';
import 'package:reef_mobile_app/model/metadata/MetadataCtrl.dart';
import 'package:reef_mobile_app/model/navigation/NavigationCtrl.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/network/NetworkCtrl.dart';
import 'package:reef_mobile_app/model/stealthex/stealthexCtrl.dart';
import 'package:reef_mobile_app/model/storage/StorageCtrl.dart';
import 'package:reef_mobile_app/model/signing/SigningCtrl.dart';
import 'package:reef_mobile_app/model/swap/PoolsCtrl.dart';
import 'package:reef_mobile_app/model/swap/SwapCtrl.dart';
import 'package:reef_mobile_app/model/tokens/TokensCtrl.dart';
import 'package:reef_mobile_app/model/transfer/TransferCtrl.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/service/WalletConnectService.dart';

import 'account/AccountCtrl.dart';

class ReefAppState {
  static ReefAppState? _instance;

  final ViewModel model = ViewModel();

  late StorageService storage;
  late WalletConnectService walletConnect;
  late TokenCtrl tokensCtrl;
  late PoolsCtrl poolsCtrl;
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
  late StealthexCtrl stealthexCtrl;
  late ReefChainApi reefChainApi;
  StreamController<String> initStatusStream = StreamController<String>();

  ReefAppState._();

  static ReefAppState get instance => _instance ??= ReefAppState._();

  init(JsApiService _jsApi, StorageService storage, WalletConnectService walletConnect,ReefChainApi _reefChainApi) async {
    this.storage = storage;
    this.reefChainApi = _reefChainApi;
    this.walletConnect = walletConnect;

  await Future.delayed(Duration(milliseconds: 100));
    // added initial delay so as to wait for the controller to set in ios
    reefChainApi.ready.future.then((_)async{
          this.initStatusStream.add("starting reefChainApi...");
      debugPrint("reefChainApi READYYYY");
      await reefChainApi.ready.future;
       this.initStatusStream.add("finshined reefChainApi init...");
      });

    this.initStatusStream.add("observables...");
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("network...");
    networkCtrl = NetworkCtrl(storage, model.network,_reefChainApi);
    firebaseAnalyticsCtrl = FirebaseAnalyticsCtrl(_reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    stealthexCtrl = StealthexCtrl(model.stealthexModel,_reefChainApi);
    this.initStatusStream.add("tokens...");
    tokensCtrl = TokenCtrl(model.tokens,reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("account...");
    accountCtrl = AccountCtrl(storage, model.accounts,reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("signer...");
    signingCtrl = SigningCtrl(storage, model.signatureRequests, model.accounts,reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("transfers...");
    transferCtrl = TransferCtrl(reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("swap...");
    swapCtrl = SwapCtrl(model.swapSettings,reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("pools...");
    poolsCtrl = PoolsCtrl(model.pools,reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("metadata...");
    metadataCtrl = MetadataCtrl(reefChainApi);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("navigation...");
    navigationCtrl =
        NavigationCtrl(model.navigationModel, model.homeNavigationModel);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("state...");


  await Future.delayed(Duration(milliseconds: 100));
    appConfigCtrl = AppConfigCtrl(storage, model.appConfig);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("locale...");
    localeCtrl = LocaleCtrl(storage, model.locale);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("storage...");
    storageCtrl = StorageCtrl(storage);
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("complete");


        Network currentNetwork =
        await storage.getValue(StorageKey.network.name) == Network.testnet.name
            ? Network.testnet
            : Network.mainnet;
    
  await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("current network===$currentNetwork");
    try {
          await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("init networ started");
      await _initReefState(_jsApi,currentNetwork,_reefChainApi);

      await Future.delayed(Duration(milliseconds: 100));
    this.initStatusStream.add("init networ finished");
    return;
    } catch (e){
      this.initStatusStream.add("error state= ${e.toString()}");
    }
    return;
  }

  _initReefState(JsApiService _jsApi, Network currentNetwork,ReefChainApi _reefChainApi) async {
        this.initStatusStream.add("init networ accounts");
    // var accounts = [];
    var accounts = await accountCtrl.getStorageAccountsList();
  
    List<ReefAccount> parsedAccounts = [];

    for(var i=0;i<accounts.length;i++){
      parsedAccounts.add(ReefAccount(accounts[i]['name'], accounts[i]['address'], false));
    }

            this.initStatusStream.add("init networ parsed accounts");

            await _jsApi.jsPromise(
        'window.jsApi.initReefState("${currentNetwork}", ${jsonEncode(
            accounts)})');

            var x =  await _jsApi.jsPromise('window.keyring.generate()');
               this.initStatusStream.add("x===$x");

    // await reefChainApi.reefState.init(currentNetwork.name=="mainnet"?ReefNetowrk.mainnet:ReefNetowrk.testnet, parsedAccounts);
  }
}
