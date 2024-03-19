import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:rxdart/rxdart.dart';

class MetadataCtrl {
  final JsApiService jsApi;

  Stream<bool>? _jsConnStream;

  MetadataCtrl(this.jsApi) {
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

  Future<bool> isJsConn() => jsApi.jsCall('window.isJsConn();').then((value) {
    if(kDebugMode) {
      print('JS=$value');
    }
    return value=='true';
  });

  Stream<bool> getJsConnStream() {
    if(_jsConnStream==null) {
      this._jsConnStream = Stream.periodic(Duration(milliseconds: 5000)).asyncMap((_) =>
              this.isJsConn()).onErrorReturn(false)
              .startWith(false)
              .asBroadcastStream();
    }
    return _jsConnStream!;
}

 }
