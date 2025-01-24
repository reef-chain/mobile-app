import 'dart:convert';

import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/network/ws-conn-state.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/service/StorageService.dart';

enum Network { mainnet, testnet }

class NetworkCtrl {
  final StorageService storage;
  final ReefChainApi reefChainApi;
  NetworkModel networkModel;

  NetworkCtrl(this.storage,  this.networkModel,this.reefChainApi) {
     reefChainApi.reefState.networkApi.selectedNetwork$
        .listen((network) async {
          print("selected network===$network");
      networkModel.setSelectedNetworkSwitching(false);
      if (network != null && network['name'] != null) {
        var nName = network['name'];
        await storage.setValue(StorageKey.network.name, nName);
        networkModel.setSelectedNetworkName(nName);
      }
    });
  }

  Future<void> setNetwork(Network network) async {
    print("here i am");
    networkModel.setSelectedNetworkSwitching(true);
    reefChainApi.reefState.networkApi.setNetwork(network.name);
  }

  Stream<bool?> getIndexerConnected()=> reefChainApi.getIndexerConnected().map((event)=>event==true);

  Stream<WsConnState?> getProviderConnLogs()=> reefChainApi.getProviderConnLogs();

  Future<void> reconnectProvider() async {
    reefChainApi.reconnectProvider();
  }

}
