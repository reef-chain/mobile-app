import 'dart:convert';

import 'package:reef_mobile_app/service/JsApiService.dart';


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
    await _jsApi.jsCallVoidReturn(
        'window.firebase.logFirebaseAnalytic(${jsonEncode(_config)},"$eventName")');
  }
}
