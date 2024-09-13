import 'dart:convert';

import 'package:reef_mobile_app/model/stealthex/stealthex_model.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';


class StealthexCtrl {
  final JsApiService _jsApi;
  final StealthexModel stealthexModel;

  StealthexCtrl(this._jsApi,this.stealthexModel) {}

   Future<dynamic> listCurrencies() async {
   return await _jsApi.jsPromise(
        'window.stealthex.listCurrencies()');
  }

   Future<dynamic> getEstimatedExchange(String sourceChain,String sourceNetwork,double amount) async {
   return await _jsApi.jsPromise(
        'window.stealthex.getEstimatedExchange("${sourceChain}","${sourceNetwork}",${amount})');
  }

   Future<dynamic> getExchangeRange(String fromSymbol,String fromNetwork) async {
   return await _jsApi.jsPromise(
        'window.stealthex.getExchangeRange("${fromSymbol}","${fromNetwork}")');
  }
   Future<dynamic> createExchange(String fromSymbol,String fromNetwork,String toSymbol,String toNetwork,double amount,String address) async {
   return await _jsApi.jsPromise(
        'window.stealthex.createExchange("${fromSymbol}","${fromNetwork}","${toSymbol}","${toNetwork}",${amount},"${address}")');
  }

   Future<dynamic> setTransactionHash(String id,String tx_hash) async {
   return await _jsApi.jsPromise(
        'window.stealthex.setTransactionHash("${id}","${tx_hash}")');
  }

  Future<void> cacheCurrencies()async{
    var currencies = await listCurrencies();
    stealthexModel.setCurrencies(currencies);
  }
}
