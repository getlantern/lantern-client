import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'model.dart';

class ModelEventChannel extends EventChannel {
  var nextSubscriberID = new Random(DateTime.now().millisecondsSinceEpoch);
  final subscribers = Map<int, Subscriber>();
  final subscriptions = Map<int, StreamSubscription>();

  ModelEventChannel(String name) : super(name);

  void Function() subscribe<T>(String path,
      {bool details,
      int count,
      @required void onUpdates(Iterable<PathAndValue<T>> updates),
      @required void onDeletes(Iterable<String> deletedPaths),
      T deserialize(Uint8List serialized)}) {
    var subscriberID = nextSubscriberID.nextInt(2^31);
    developer.log("subscribing with id $subscriberID to $path");
    var arguments = {
      "subscriberID": subscriberID,
      "path": path,
      "count": count,
      "details": details
    };
    subscribers[subscriberID] =
        Subscriber<T>(onUpdates, onDeletes, deserialize);
    var stream = receiveBroadcastStream(arguments);
    subscriptions[subscriberID] = listen(stream);
    return () {
      var subscription = subscriptions.remove(subscriberID);
      if (subscription != null) {
        developer.log("canceling subscription for $path");
        subscribers.remove(subscriberID);
        subscription.cancel();
        if (subscribers.isNotEmpty) {
          listen(stream);
        }
      }
    };
  }

  StreamSubscription listen(Stream<dynamic> stream) {
    return stream.listen((dynamic event) {
      var m = event as Map;
      var subscriberID = m['s'];
      var subscriber = subscribers[subscriberID];
      if (subscriber == null) {
        return;
      }
      var updates = m['u'];
      if (updates != null) {
        subscriber.onUpdates((updates as List<dynamic>).map((e) {
          var u = e as List<dynamic>;
          return PathAndValue(u[0] as String, u[1]);
        }));
      }
      var deletes = m['d'];
      if (deletes != null) {
        subscriber.onDeletes(deletes as Iterable<String>);
      }
    });
  }
}

class Subscriber<T> {
  void Function(Iterable<PathAndValue<T>> updates) wrappedOnUpdates;

  void Function(Iterable<String> deletions) onDeletes;

  T Function(Uint8List serialized) deserialize;

  Subscriber(this.wrappedOnUpdates, this.onDeletes, this.deserialize);

  void onUpdates(Iterable<PathAndValue<dynamic>> updates) {
    if (deserialize != null) {
      wrappedOnUpdates(
          updates.map((u) => PathAndValue(u.path, deserialize(u.value))));
    } else {
      wrappedOnUpdates(updates.map((u) => PathAndValue(u.path, u.value as T)));
    }
  }
}
