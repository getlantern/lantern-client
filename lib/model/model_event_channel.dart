import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'protobuf_message_codec.dart';

class ModelEventChannel extends EventChannel {
  var nextSubscriberID = 0;
  final subscribers = Map<int, Function>();
  final subscriptions = Map<int, StreamSubscription>();

  ModelEventChannel(String name)
      : super(name, StandardMethodCodec(ProtobufMessageCodec()));

  void Function() subscribe<T>(
      {@required String path,
        String prefixPath,
        void onNewValue(T newValue)}) {
    var subscriberID = nextSubscriberID++;
    subscribers[subscriberID] = onNewValue;
    var arguments = {"subscriberID": subscriberID, "path": path};
    if (prefixPath != null) {
      arguments["prefixPath"] = prefixPath;
    }
    var stream = receiveBroadcastStream(arguments);
    subscriptions[subscriberID] = listen(stream);
    return () {
      var subscription = subscriptions.remove(subscriberID);
      if (subscription != null) {
        subscribers.remove(subscriberID);
        subscription.cancel();
        if (subscribers.isNotEmpty) {
          listen(stream);
        }
      }
    };
  }

  StreamSubscription listen(Stream<dynamic> stream) {
    return stream.listen((dynamic update) {
      var updateMap = update as Map;
      var subscriberID = updateMap["subscriberID"];
      var newValue = updateMap["newValue"];
      var subscriber = subscribers[subscriberID];
      if (subscriber != null) {
        subscriber(newValue);
      }
    });
  }
}
