import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class ModelEventChannel extends EventChannel {
  var nextSubscriberID = 0;
  final subscribers = Map<int, Function>();
  final subscriptions = Map<int, StreamSubscription>();

  ModelEventChannel(String name) : super(name);

  void Function() subscribe<T>(String path,
      {String prefixPath,
      @required void onNewValue(T newValue),
      T deserialize(Uint8List serialized)}) {
    var subscriberID = nextSubscriberID++;
    var arguments = {"subscriberID": subscriberID, "path": path};
    if (prefixPath != null) {
      arguments["prefixPath"] = prefixPath;
    }
    if (deserialize != null) {
      arguments["raw"] = true;
      subscribers[subscriberID] = (Uint8List serialized) {
        onNewValue(serialized == null ? null : deserialize(serialized));
      };
    } else {
      subscribers[subscriberID] = onNewValue;
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
