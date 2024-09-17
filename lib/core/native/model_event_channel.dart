import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';

import '../utils/common.dart';

class ModelEventChannel extends EventChannel {
  var uuid = const Uuid();

  final subscribers = <String, Subscriber>{};
  final subscriptions = <String, StreamSubscription>{};

  ModelEventChannel(String name) : super(name);

  void Function() subscribe<T>(
    String path, {
    bool details = false,
    int count = 2 << 31,
    required void Function(Map<String, T> updates, Iterable<String> deletions)
        onChanges,
    T Function(Uint8List serialized)? deserialize,
  }) {
    var subscriberID = uuid.v4();
    var arguments = {
      'subscriberID': subscriberID,
      'path': path,
      'count': count,
      'details': details
    };
    subscribers[subscriberID] = Subscriber<T>(onChanges, deserialize);
    var stream = receiveBroadcastStream(arguments);
    subscriptions[subscriberID] = listen(stream);
    return () {
      var subscription = subscriptions.remove(subscriberID);
      if (subscription != null) {
        developer.log('canceling subscription for $path');
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
      var deletes = m['d'];
      subscriber.onChanges(updates, deletes);
    });
  }
}

class Subscriber<T> {
  void Function(Map<String, T>, Iterable<String>) wrappedOnChanges;

  T Function(Uint8List serialized)? deserialize;

  Subscriber(this.wrappedOnChanges, this.deserialize);

  void onChanges(Map<dynamic, dynamic> _updates, List<dynamic> _deletions) {
    var deletions = _deletions.map((path) => path as String);
    Map<String, T> updates;
    if (deserialize != null) {
      updates = _updates.map(
        (key, value) =>
            MapEntry(key as String, deserialize!(value as Uint8List)),
      );
    } else {
      updates =
          _updates.map((key, value) => MapEntry(key as String, value as T));
    }
    wrappedOnChanges(updates, deletions);
  }
}
