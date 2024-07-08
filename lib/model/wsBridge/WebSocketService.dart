import 'dart:async';
import 'dart:convert';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  late WebSocketChannel _channel;
  final JsApiService jsApiService;
  final String url;

  WebSocketService(String network, this.jsApiService)
      : url = network == 'mainnet'
            ? 'wss://rpc.reefscan.com/ws'
            : 'wss://rpc-testnet.reefscan.com/ws' {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _listen();
  }

  void _listen() {
    _channel.stream.listen(
      (message) {
final String jsFunctionCall = "window.reefStateInitMethods.onFlutterWsResponse(`$message`)";

jsApiService.jsPromise(jsFunctionCall);
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('Connection closed.');
      },
    );
  }

  void send(Map<String, dynamic> data) {
    print("sending on ${this.url}");
    _channel.sink.add(data['data'].toString());
  }

  void close() {
    _channel.sink.close(status.goingAway);
  }
}