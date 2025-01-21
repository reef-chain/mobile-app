import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:rxdart/rxdart.dart';

class MetadataCtrl {
  final ReefChainApi _reefChainApi;

  bool resolveBooleanValue(dynamic res) {
    return res == true ||
        res == 'true' ||
        res == 1 ||
        res == '1' ||
        res == '"true"';
  }

  final StreamController<bool> _jsConnStreamCtrl = new StreamController();
  late Stream<bool> _jsStream;
  bool _jsConn = false;

  MetadataCtrl(this._reefChainApi) {
    _jsStream = _jsConnStreamCtrl.stream.asBroadcastStream();
    Timer.periodic(Duration(milliseconds: 5000), (timer) async {
      _jsConn = await this.isJsConn();
      this._jsConnStreamCtrl.add(_jsConn);
    });
  }

  Future<dynamic> getMetadata() => _reefChainApi.reefState.metadataApi.getMetadata();

  Future<dynamic> getJsVersions() => _reefChainApi.reefState.metadataApi.getJsVersions();

  Future<bool> isJsConn() => _reefChainApi.reefState.metadataApi.isJsConn().then((value) {
        if (kDebugMode) {
          print('JS CONN=$value');
        }
        return resolveBooleanValue(value);
      }).onError((error, stackTrace) => false);

  Future<Stream<bool>> getJsConnStream() async {
    Future.delayed(Duration(milliseconds: 10)).then((_) =>this.isJsConn()).then((conn)=> this._jsConnStreamCtrl.add(conn)).onError((_,__) {this._jsConnStreamCtrl.add(false);});
    return _jsStream;
  }
}
