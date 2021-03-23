import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class ModelEventChannel extends EventChannel {
  var nextSubscriberID = new Random(DateTime.now().millisecondsSinceEpoch)
      .nextInt(2 ^
          32); // Start with a random value to work well with hot restart in dev
  final subscribers = Map<int, Function>();
  final subscriptions = Map<int, StreamSubscription>();

  ModelEventChannel(String name) : super(name);

  void Function() subscribe<T>(String path,
      {bool details,
      bool tail,
      int count,
      @required void onNewValue(T newValue),
      T deserialize(Uint8List serialized)}) {
    var subscriberID = nextSubscriberID++;
    var arguments = {
      "subscriberID": subscriberID,
      "path": path,
      "tail": tail,
      "count": count,
      "details": details
    };
    if (deserialize != null) {
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

  void Function() tail<T>(String path,
      {details: bool,
      int count = 2 ^ 32,
      @required void onNewValue(List<T> newValue),
      T deserialize(Uint8List serialized)}) {
    return subscribe(path, tail: true, details: details, count: count,
        onNewValue: (List<dynamic> list) {
      onNewValue(list.map((e) => deserialize(e)).toList());
    });
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
