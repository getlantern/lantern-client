import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lantern/common/common_desktop.dart';

abstract class WebsocketService {
  Stream<Map<String, dynamic>> get messageStream;
  Future<void> connect();
  Future<void> close();
  void send(String event, Map<String, dynamic> data);
}

class WebsocketImpl implements WebsocketService {

  static final WebsocketImpl _websocket = WebsocketImpl._internal();

  factory WebsocketImpl() {
    return _websocket;
  }

  WebsocketImpl._internal();

  StreamController<Map<String, dynamic>> streamController = StreamController<Map<String, dynamic>>.broadcast();
  WebSocketChannel? _channel;
  bool _isConnected = false;

  @override
  Stream<Map<String, dynamic>> get messageStream => streamController.stream;

  @override
  Future<void> connect() async {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://" + websocketAddr() + '/data'),
    );

    _channel!.stream.listen(
      (message) async {
        final Map<String, dynamic> json = jsonDecode(message ?? {});
        streamController.add(json);
      },
      onDone: () async {
        await close();
      },
      onError: (error) => _handleError(error),
    );

    _isConnected = true;

    print("Websocket connected");  
  }

  void _handleError(dynamic error) {
    if (error is WebSocketChannelException) {
      close();
      return;
    }

    print('Websocket error: $error');
  }

  @override
  Future<void> close() async {
    if (_channel != null && _channel?.sink != null) {
      await _channel?.sink.close();
    }
    _isConnected = false;
  }

  @override
  void send(String event, Map<String, dynamic> data) {
    if (_channel != null && _channel?.sink != null) {
      data['type'] = event;

      _channel!.sink.add(jsonEncode(data));
    } else {
      print('Websocket is not connected');
    }
  }
}