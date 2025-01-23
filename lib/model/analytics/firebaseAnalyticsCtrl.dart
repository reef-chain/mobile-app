import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';


class FirebaseAnalyticsCtrl {
  final ReefChainApi _reefChainApi;
  Map<String,String>? _config;

  FirebaseAnalyticsCtrl(this._reefChainApi) {
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
    return await _reefChainApi.reefState.firebaseApi.logAnalytics(eventName, _config);
  }
}
