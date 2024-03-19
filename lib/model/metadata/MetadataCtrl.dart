import 'dart:async';

import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:rxdart/rxdart.dart';

class MetadataCtrl {
  final JsApiService jsApi;

  MetadataCtrl(this.jsApi) {
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

  Future<bool> isJsConn() => jsApi.jsCall('window.isJsConn();').then((value) {
        return value=='true';
  });

  Stream<bool> getJsConnStream() => Stream.periodic(Duration(milliseconds: 800)).asyncMap((_)=>this.isJsConn()).onErrorReturn(false).asBroadcastStream();

 }
