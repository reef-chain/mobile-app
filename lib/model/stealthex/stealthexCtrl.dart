import 'dart:convert';

import 'package:reef_mobile_app/service/JsApiService.dart';


class StealthexCtrl {
  final JsApiService _jsApi;
  String? bearerToken; 

  StealthexCtrl(this._jsApi) {
    // anukulpandey undo later
    // bearerToken = const String.fromEnvironment("STEALTHEX_BEARER_TOKEN", defaultValue: "");
    bearerToken = "4500da35-f5d0-4783-873e-8677f85e4f21";
  }

   Future<dynamic> listCurrencies() async {
   return await _jsApi.jsPromise(
        'window.stealthex.listCurrencies("${bearerToken}")');
  }

   Future<dynamic> getEstimatedExchange(String sourceChain,String sourceNetwork,double amount) async {
   return await _jsApi.jsPromise(
        'window.stealthex.getEstimatedExchange("${bearerToken}","${sourceChain}","${sourceNetwork}",${amount})');
  }
   Future<dynamic> createExchange(String sourceChain,String fromSymbol,String toSymbol,String toNetwork,double amount,String address) async {
   return await _jsApi.jsPromise(
        'window.stealthex.createExchange("${bearerToken}","${fromSymbol}","${toSymbol}","${toSymbol}","${toNetwork}",${amount},"${address}")');
  }
}
