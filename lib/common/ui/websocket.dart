import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lantern/common/common_desktop.dart';

abstract class WebsocketService {
  Stream<Map<String, dynamic>> get messageStream;
  Future<void> connect(Uri uri);
  Future<void> close();
  void send(String event, Map<String, dynamic> data);
}

class WebsocketImpl implements WebsocketService {
  static final WebsocketImpl _websocket = WebsocketImpl._internal();

  factory WebsocketImpl() {
    return _websocket;
  }

  WebsocketImpl._internal();

  // streamController is used to control the websocket stream channel
  StreamController<Map<String, dynamic>> streamController =
      StreamController<Map<String, dynamic>>.broadcast();
  // _channel is a stream channel that communicates over a WebSocket.
  WebSocketChannel? _channel;
  bool _isConnected = false;

  @override
  Stream<Map<String, dynamic>> get messageStream => streamController.stream;

  // Creates a new Websocket connection
  @override
  Future<void> connect(Uri uri) async {
    _channel = WebSocketChannel.connect(uri);

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

  // Close sink for sending values and websocket connection
  @override
  Future<void> close() async {
    if (_channel != null && _channel?.sink != null) {
      await _channel?.sink.close();
    }
    _isConnected = false;
  }

  // Send data over a websocket channel
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
