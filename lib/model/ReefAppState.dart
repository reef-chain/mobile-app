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

import 'account/account_ctrl.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';
// ...your other imports...

enum AppInitState { uninitialized, initializing, initialized, failed }

class ReefAppState {
  static ReefAppState? _instance;
  ReefAppState._();
  static ReefAppState get instance => _instance ??= ReefAppState._();

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

  Completer<void>? _initCall;
  AppInitState _initState = AppInitState.uninitialized;

  // ✅ Broadcast so multiple StreamBuilders/subscribers are OK
  final StreamController<String> initStatusStream =
  StreamController<String>.broadcast();

  bool get isInitialized => _initState == AppInitState.initialized;
  bool get isInitializing => _initState == AppInitState.initializing;

  void _emit(String s) {
    if (!initStatusStream.isClosed) {
      try { initStatusStream.add(s); } catch (_) {}
    }
  }

  Future<void> init(
      StorageService storage,
      WalletConnectService walletConnect,
      ReefChainApi api,
      ) async {
    // If one init is running, await it.
    if (isInitializing && _initCall != null) {
      await _initCall!.future;
      return;
    }
    // If done, skip.
    if (isInitialized) return;

    _initState = AppInitState.initializing;
    _initCall = Completer<void>();

    this.storage = storage;
    this.walletConnect = walletConnect;
    this.reefChainApi = api;

    try {
      _emit("reefApi...");
      // ⏳ Robust timeout
      await api.ready.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException("ReefChainApi init timed out"),
      );

      _emit("network...");
      networkCtrl = NetworkCtrl(storage, model.network, api);

      _emit("analytics...");
      firebaseAnalyticsCtrl = FirebaseAnalyticsCtrl(api);

      _emit("stealthex...");
      stealthexCtrl = StealthexCtrl(model.stealthexModel, api);

      _emit("tokens...");
      tokensCtrl = TokenCtrl(model.tokens, api);

      _emit("account...");
      accountCtrl = AccountCtrl(storage, model.accounts, api);

      _emit("signer...");
      signingCtrl = SigningCtrl(storage, model.signatureRequests, model.accounts, api);

      _emit("transfers...");
      transferCtrl = TransferCtrl(api);

      _emit("swap...");
      swapCtrl = SwapCtrl(model.swapSettings, api);

      _emit("pools...");
      poolsCtrl = PoolsCtrl(model.pools, api);

      _emit("metadata...");
      metadataCtrl = MetadataCtrl(api);

      _emit("navigation...");
      navigationCtrl = NavigationCtrl(model.navigationModel, model.homeNavigationModel);

      _emit("config...");
      appConfigCtrl = AppConfigCtrl(storage, model.appConfig);

      _emit("locale...");
      localeCtrl = LocaleCtrl(storage, model.locale);

      _emit("storage...");
      storageCtrl = StorageCtrl(storage);

      _emit("network-select...");
      final storedNet = await storage.getValue(StorageKey.network.name);
      final currentNetwork =
      storedNet == Network.testnet.name ? Network.testnet : Network.mainnet;

      _emit("reefState...");
      await _initReefState(currentNetwork, api);

      _emit("complete");
      _initState = AppInitState.initialized;
      _initCall!.complete();
    } catch (e, st) {
      _emit("error state= ${e.toString()}");
      _initState = AppInitState.failed;
      if (!(_initCall?.isCompleted ?? true)) {
        _initCall!.completeError(e, st);
      }
      // ❗ allow retries later
      _initCall = null;
      rethrow;
    }
  }

  Future<void> _initReefState(Network currentNetwork, ReefChainApi api) async {
    final accounts = await accountCtrl.getStorageAccountsList();
    final parsedAccounts = <ReefAccount>[
      for (final a in accounts) ReefAccount(a['name'], a['address'], false),
    ];
    await api.reefState.init(
      currentNetwork.name == "mainnet" ? ReefNetowrk.mainnet : ReefNetowrk.testnet,
      parsedAccounts,
    );
  }
}
