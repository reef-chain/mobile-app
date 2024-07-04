import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/service/JsApiService.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WsBridge {
  final String _url;
  late final WebSocketChannel channel;
  Function(String message)? onMessage;

  WsBridge(this._url);

  Future<void> connect() async {
    print("Establishing connection with $_url");

    ReefAppState.instance.poolsCtrl.connectWsBridge(_url).then((x)=>print("x-- ${x}"));

   

    channel = WebSocketChannel.connect(
      Uri.parse(_url),
    );

    channel.stream.listen(
      (data) {
        if (onMessage != null) {
          onMessage!(data);
        } else {
          print('Received: $data');
        }
      },
      onError: (error) => print('WebSocket error: $error'),
      onDone: () => print('WebSocket connection closed'),
    );
  }

  void send(String message) {
    if (channel != null) {
      print('Sending: $message');
      channel.sink.add(message);
    } else {
      print('WebSocket is not connected');
    }
  }

  void close() {
    if (channel != null) {
      channel.sink.close(status.goingAway);
      print('WebSocket connection closed');
    }
  }
}