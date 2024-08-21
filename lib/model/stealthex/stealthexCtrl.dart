import 'dart:convert';

import 'package:reef_mobile_app/model/stealthex/stealthex_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';


class StealthexCtrl {
  final JsApiService _jsApi;
  final StealthexModel stealthexModel;
  String? bearerToken; 

  StealthexCtrl(this._jsApi,this.stealthexModel) {
    // bearerToken = const String.fromEnvironment("STEALTHEX_BEARER_TOKEN", defaultValue: "");
    bearerToken = "4500da35-f5d0-4783-873e-8677f85e4f21";

    listCurrencies().then((_currencies){
      stealthexModel.setCurrencies(_currencies);
    });
  }

   Future<dynamic> listCurrencies() async {
   return await _jsApi.jsPromise(
        'window.stealthex.listCurrencies("${bearerToken}")');
  }

   Future<dynamic> getEstimatedExchange(String sourceChain,String sourceNetwork,double amount) async {
   return await _jsApi.jsPromise(
        'window.stealthex.getEstimatedExchange("${bearerToken}","${sourceChain}","${sourceNetwork}",${amount})');
  }
   Future<dynamic> createExchange(String fromSymbol,String fromNetwork,String toSymbol,String toNetwork,double amount,String address) async {
   return await _jsApi.jsPromise(
        'window.stealthex.createExchange("${bearerToken}","${fromSymbol}","${fromNetwork}","${toSymbol}","${toNetwork}",${amount},"${address}")');
  }

   Future<dynamic> setTransactionHash(String id,String tx_hash) async {
   return await _jsApi.jsPromise(
        'window.stealthex.setTransactionHash("${bearerToken}","${id}","${tx_hash}")');
  }
}
