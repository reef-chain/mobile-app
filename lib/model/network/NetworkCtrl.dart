import 'dart:convert';

import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/model/network/ws-conn-state.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

enum Network { mainnet, testnet }

class NetworkCtrl {
  final StorageService storage;
  final JsApiService jsApi;
  final ReefChainApi reefChainApi;
  NetworkModel networkModel;

  NetworkCtrl(this.storage, this.jsApi, this.networkModel,this.reefChainApi) {
     reefChainApi.reefState.networkApi.selectedNetwork$
        .listen((network) async {
      networkModel.setSelectedNetworkSwitching(false);
      if (network != null && network['name'] != null) {
        var nName = network['name'];
        await storage.setValue(StorageKey.network.name, nName);
        networkModel.setSelectedNetworkName(nName);
      }
    });

    // need to listen here so other subscriptions immediately receive last value
    getProviderConnLogs().listen((event) {print('PROV CONN=$event');});
  }

  Future<void> setNetwork(Network network) async {
    networkModel.setSelectedNetworkSwitching(true);
    reefChainApi.reefState.networkApi.setNetwork(network.name);
  }

  Stream<bool?> getIndexerConnected()=> reefChainApi.getIndexerConnected().map((event)=>event==true);

  Stream<WsConnState?> getProviderConnLogs()=> reefChainApi.getProviderConnLogs().map((event) => WsConnState.fromJson(event));

  Future<void> reconnectProvider() async {
    reefChainApi.reconnectProvider();
  }

}
