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

   Future<dynamic> listExchanges() async {
    await _jsApi.jsCallVoidReturn(
        'window.stealthex.listExchanges("${bearerToken}")');
  }
}
