import 'dart:async';
import 'dart:convert';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class NetworkWs {
  static NetworkChannel? _connectedChannel;

  static void send(Map<String, dynamic> data, String network, JsApiService jsApiService, String jsResponseFn){
    // TODO
    // need to check if WebSocketService.activeChannel has same network - if not close current activeChannel and listen to new network
    // so we have one channel open/saved for last send network request and we can use static context for that
    //
    // we need to make sure we don't connect again when connection is in progress so would need to get channel from method that awaits
    getConnectedChannel(network, jsApiService).send(data);
  }

  static NetworkChannel getConnectedChannel(String network, JsApiService jsApiService) {
    if(_connectedChannel==null) {
      _connectedChannel = NetworkChannel(network, jsApiService);
    } else if ( _connectedChannel!.network != network){
        _connectedChannel!.close();
        _connectedChannel = NetworkChannel(network, jsApiService);
    }
    return _connectedChannel!;
  }
}

class NetworkChannel {
  final String network;
  final String _url;
  final JsApiService _jsApiService;
  WebSocketChannel? _channel;
  bool isBuffering = true;
  List<dynamic> bufferingData = [];

  NetworkChannel(this.network, this._jsApiService): _url = network == 'mainnet'
      ? 'wss://rpc.reefscan.com/ws'
      : 'wss://rpc-testnet.reefscan.com/ws'{
    this._connect();
  }

  void send(data){
    if(isBuffering) {
      bufferingData!.add(data);
      return;
    }

    print("sending on ${this._url}");
    _channel?.sink.add(data['data'].toString());

  }

  void sendBufferData(){
    isBuffering=false;
    for (var data in bufferingData) {
      send(data);
    }
  }

  Future<void> _connect() async {
    _channel = WebSocketChannel.connect(Uri.parse(_url));
    _listen(_channel!, _jsApiService);
    await _channel!.ready;
    sendBufferData();
  }

  close(){
    _channel?.sink.close(status.goingAway);
  }

  void _listen(WebSocketChannel channel, JsApiService jsApiService) {
    channel.stream.listen(
          (message) {
        final String jsFunctionCall = "window.reefStateInitMethods.onFlutterWsResponse(`$message`)";
        jsApiService.jsCallVoidReturn(jsFunctionCall);
      },
      onError: (error) {
        print('ActiveChannel Error: $error');
      },
      onDone: () {
        print('ActiveChannel Connection closed.');
      },
    );
  }


}