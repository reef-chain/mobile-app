import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:rxdart/rxdart.dart';

class MetadataCtrl {
  final JsApiService jsApi;

  final StreamController<bool> _jsConnStreamCtrl = new StreamController();
  late Stream<bool> _jsStream;
  bool _jsConn = false;

  MetadataCtrl(this.jsApi) {
    _jsStream = _jsConnStreamCtrl.stream.asBroadcastStream();
    Timer.periodic(Duration(milliseconds: 5000), (timer) async {
      _jsConn = await this.isJsConn();
      this._jsConnStreamCtrl.add(_jsConn);
    });
  }

  Future<dynamic> getMetadata() =>
      jsApi.jsPromise('window.metadata.getMetadata();');

  Future<dynamic> getJsVersions() => jsApi.jsCall('window.getReefJsVer();');

  Future<bool> isJsConn() => jsApi.jsCall('window.isJsConn();').then((value) {
        if (kDebugMode) {
          print('JS CONN=$value');
        }
        return value == 'true';
      }).onError((error, stackTrace) => false);

  Future<Stream<bool>> getJsConnStream() async {
    Future.delayed(Duration(milliseconds: 10)).then((_) =>this.isJsConn()).then((conn)=> this._jsConnStreamCtrl.add(conn)).onError((_,__) {this._jsConnStreamCtrl.add(false);});
    return _jsStream;
  }
}
