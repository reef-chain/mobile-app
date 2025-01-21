import 'dart:convert';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/stealthex/stealthex_model.dart';

class StealthexCtrl {
  final StealthexModel stealthexModel;
  final ReefChainApi _reefChainApi;

  StealthexCtrl(this.stealthexModel, this._reefChainApi) {}

  Future<dynamic> listCurrencies() async {
    return await _reefChainApi.reefState.stealthexApi.listCurrencies();
  }

  Future<dynamic> getEstimatedExchange(
      String sourceChain, String sourceNetwork, double amount) async {
    return await _reefChainApi.reefState.stealthexApi
        .getEstimatedExchange(sourceChain, sourceNetwork, amount);
  }

  Future<dynamic> getExchangeRange(
      String fromSymbol, String fromNetwork) async {
    return await _reefChainApi.reefState.stealthexApi
        .getExchangeRange(fromSymbol, fromNetwork);
  }

  Future<dynamic> createExchange(String fromSymbol, String fromNetwork,
      String toSymbol, String toNetwork, double amount, String address) async {
    return await _reefChainApi.reefState.stealthexApi.createExchange(
        fromSymbol, fromNetwork, toSymbol, toNetwork, amount, address);
  }

  Future<dynamic> setTransactionHash(String id, String tx_hash) async {
    return await _reefChainApi.reefState.stealthexApi
        .setTransactionHash(id, tx_hash);
  }

  Future<void> cacheCurrencies() async {
    var currencies = await listCurrencies();
    stealthexModel.setCurrencies(currencies);
  }
}
