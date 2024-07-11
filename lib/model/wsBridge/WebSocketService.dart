import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ActiveNetworkWs {
  static RpcWsNativeChannel? _connectedChannel;

  static RpcWsNativeChannel getConnectedChannel(
      String rpcUrl, JsApiService jsApiService, String jsResponseHandlerFn) {
    if (_connectedChannel == null) {
      _connectedChannel =
          RpcWsNativeChannel(rpcUrl, jsApiService, jsResponseHandlerFn);
    } else if (_connectedChannel!.rpcUrl != rpcUrl) {
      _connectedChannel!.close();
      _connectedChannel =
          RpcWsNativeChannel(rpcUrl, jsApiService, jsResponseHandlerFn);
    }
    return _connectedChannel!;
  }
}

class RpcWsNativeChannel {
  final String rpcUrl;
  final String _jsResponseHandlerFn;
  final JsApiService _jsApiService;
  WebSocketChannel? _channel;
  bool _isBuffering = true;
  List<dynamic> _bufferingData = [];

  RpcWsNativeChannel(
      this.rpcUrl, this._jsApiService, this._jsResponseHandlerFn) {
    this._connect();
  }

  void send(data) {
    if (_isBuffering) {
      _bufferingData.add(data);
      return;
    }

    print("sending on ${this.rpcUrl}");
    _channel?.sink.add(data['data'].toString());
  }

  void sendBufferData() {
    _isBuffering = false;
    for (var data in _bufferingData) {
      send(data);
    }
    _bufferingData.clear();
  }

  Future<void> _connect() async {
    //var rpcUrl="wss://rpc.reefscan.com/ws";
    var uri = Uri.parse(rpcUrl);
    print("rrrrrrrr= $rpcUrl");
    _channel = WebSocketChannel.connect(uri);
    _listen(_channel!, _jsApiService, rpcUrl);
    try {
      await _channel!.ready;
    } on SocketException catch (e) {
      // TODO Handle the exception - call _jsErrorHandlerFn(err, rpcUrl)

      return;
    } on WebSocketChannelException catch (e) {
      //TODO Handle the exception - call _jsErrorHandlerFn(err, rpcUrl)

      return;
    }
    // TODO Handle the open - call _jsOpenHandlerFn(rpcUrl)

    sendBufferData();
  }

  close() {
    _channel?.sink.close(status.goingAway);
  }

  void _listen(
      WebSocketChannel channel, JsApiService jsApiService, String rpcUrl) {
    channel.stream.listen(
      (message) {
        final String jsFunctionCall =
            "$_jsResponseHandlerFn(`$message`, `${rpcUrl}`)";
        jsApiService.jsCallVoidReturn(jsFunctionCall);
      },
      onError: (error) {
        print('ActiveChannel Error: $error');
        // TODO Handle the exception - call _jsErrorHandlerFn(err, rpcUrl)
      },
      onDone: () {
        print('ActiveChannel Connection closed.');
        // TODO Handle the close - call _jsCloseHandlerFn(rpcUrl)
      },
    );
  }
}
