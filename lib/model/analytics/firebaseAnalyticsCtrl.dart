import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_chain_flutter/js_api_service.dart';


class FirebaseAnalyticsCtrl {
  final JsApiService _jsApi;
  Map<String,String>? _config;

  FirebaseAnalyticsCtrl(this._jsApi) {
   _config ={
      'apiKey': const String.fromEnvironment("FIREBASE_API_KEY", defaultValue: ""),
      'authDomain': const String.fromEnvironment("FIREBASE_AUTH_DOMAIN", defaultValue: ""),
      'projectId':  const String.fromEnvironment("FIREBASE_PROJECT_ID", defaultValue: ""),
      'storageBucket': const String.fromEnvironment("FIREBASE_STORAGE_BUCKET", defaultValue: ""),
      'messagingSenderId': const String.fromEnvironment("FIREBASE_MESSAGING_SENDER_ID", defaultValue: ""),
      'appId': const String.fromEnvironment("FIREBASE_APP_ID", defaultValue: ""),
      'measurementId': const String.fromEnvironment("FIREBASE_MEASUREMENT_ID", defaultValue: ""),
    };
  }

   Future<dynamic> logAnalytics(String eventName) async {
    try {  
      await _jsApi.jsCallVoidReturn(
        'window.firebase.logFirebaseAnalytic(${jsonEncode(_config)},"$eventName")');
    } catch (e) {
      debugPrint("unable to log to firebase");
    }
  }
}
