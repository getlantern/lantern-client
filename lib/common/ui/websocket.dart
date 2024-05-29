import 'dart:async';

import 'package:lantern/common/common_desktop.dart';

abstract class WebsocketService {
  Stream<Map<String, dynamic>> get messageStream;
  Future<void> connect();
  Future<void> close();
  void send(String event, Map<String, dynamic> data);
}

class WebsocketImpl implements WebsocketService {
  static WebsocketImpl? _websocket;
  WebsocketImpl._internal();

  // the maximum number of times we attempt to reconnect
  static const _maxRetries = 5;
  // The number of times we've tried reconnecting
  var _retries = 0;

  Timer? _rcTimer;

  static WebsocketImpl? instance() {
    if (_websocket == null) {
      _websocket = WebsocketImpl._internal();
    }
    return _websocket;
  }

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
  Future<void> connect() async {
    final uri = Uri.parse("ws://" + websocketAddr() + '/data');
    if (_isConnected) {
      return;
    }

    print('Opening websocket connection');

    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onDone: () => _handleDone(uri),
        onError: (error) => _handleError(error),
      );

      print("Websocket connected");

      _isConnected = true;
      _retries = 0;
      _rcTimer?.cancel();
      _rcTimer = null;

    } catch (e) {
      await close();
      print("Exception opening websocket connection ${e.toString()}");
    }
  }

  void _handleError(dynamic error) {
    print('Websocket error: $error');
    close();
  }

  void _handleDone(Uri uri) {
    if (_isConnected) {
      reconnect(uri);
    }
  }

  // Close sink for sending values and websocket connection
  @override
  Future<void> close() async {
    _isConnected = false;
    if (_channel != null && _channel?.sink != null) {
      print('Closing websocket');
      await _channel?.sink.close();
    }
  }

  Future<void> _handleMessage(message) async {
    final Map<String, dynamic> json = jsonDecode(message ?? {});
    streamController.add(json);
  }

  Future<void> reconnect(Uri uri) async {
    if (_retries >= _maxRetries) {
      _rcTimer?.cancel();
      _rcTimer = null;
      return;
    }
    _retries++;
    if (_rcTimer == null) {
      _rcTimer = new Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        print('websocket reconnect');
        _channel = WebSocketChannel.connect(uri);
        _channel!.stream.listen(
          (message) => _handleMessage(message),
          onDone: () => _handleDone(uri),
          onError: (error) => _handleError(error),
        );
      });
    }
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
