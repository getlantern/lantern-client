import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lantern/model/single_value_subscriber.dart';
import 'package:meta/meta.dart';

import 'list_subscriber.dart';
import 'model_event_channel.dart';

abstract class Model {
  MethodChannel methodChannel;
  ModelEventChannel _updatesChannel;
  Map<String, SubscribedSingleValueNotifier> _singleValueNotifierCache =
      HashMap();
  Map<String, SubscribedListNotifier> _listNotifierCache = HashMap();

  Model(String name) {
    methodChannel = MethodChannel('${name}_method_channel');
    _updatesChannel = ModelEventChannel('${name}_event_channel');
  }

  Future<T> get<T>(String path) async {
    return methodChannel.invokeMethod('get', <String, dynamic>{
      'path': path,
    });
  }

  Future<List<T>> list<T>(String path,
      {int start = 0,
      int count = 2 ^ 32,
      String fullTextSearch,
      bool reverseSort,
      T deserialize(Uint8List serialized)}) async {
    var intermediate =
        await methodChannel.invokeMethod('list', <String, dynamic>{
      'path': path,
      'start': start,
      'count': count,
      'fullTextSearch': fullTextSearch,
      'reverseSort': reverseSort,
    });
    List<T> result = [];
    if (deserialize != null) {
      intermediate
          .forEach((element) => result.add(deserialize(element as Uint8List)));
    } else {
      intermediate.forEach((element) => result.add(element as T));
    }
    return result;
  }

  ValueListenableBuilder<T> subscribedSingleValueBuilder<T>(String path,
      {T defaultValue,
      @required ValueWidgetBuilder<T> builder,
      bool details,
      T deserialize(Uint8List serialized)}) {
    var notifier = singleValueNotifier(path, defaultValue,
        details: details, deserialize: deserialize);
    return SubscribedSingleValueBuilder<T>(path, notifier, builder);
  }

  ValueNotifier<T> singleValueNotifier<T>(String path, T defaultValue,
      {bool details, T deserialize(Uint8List serialized)}) {
    SubscribedSingleValueNotifier<T> result = _singleValueNotifierCache[path];
    if (result == null) {
      result = SubscribedSingleValueNotifier(
          path, defaultValue, _updatesChannel, () {
        _singleValueNotifierCache.remove(path);
      }, details: details, deserialize: deserialize);
      _singleValueNotifierCache[path] = result;
    }
    return result;
  }

  ValueListenableBuilder<ChangeTrackingList<T>> subscribedListBuilder<T>(
      String path,
      {@required ValueWidgetBuilder<List<PathAndValue<T>>> builder,
      bool details,
      int compare(String key1, String key2),
      T deserialize(Uint8List serialized)}) {
    var notifier = listNotifier(path,
        details: details, compare: compare, deserialize: deserialize);
    return SubscribedListBuilder<T>(
        path,
        notifier,
        (BuildContext context, ChangeTrackingList<T> value, Widget child) =>
            builder(
                context,
                value.map.entries
                    .map((e) => PathAndValue(e.key, e.value))
                    .toList(),
                child));
  }

  ValueNotifier<ChangeTrackingList<T>> listNotifier<T>(String path,
      {bool details,
      int compare(String key1, String key2),
      T deserialize(Uint8List serialized)}) {
    SubscribedListNotifier<T> result = _listNotifierCache[path];
    if (result == null) {
      result = SubscribedListNotifier(path, _updatesChannel, () {
        _listNotifierCache.remove(path);
      }, details: details, compare: compare, deserialize: deserialize);
      _listNotifierCache[path] = result;
    }
    return result;
  }

  ValueListenableBuilder<T> listChildBuilder<T>(
      BuildContext context, String path,
      {T defaultValue, ValueWidgetBuilder<T> builder}) {
    return ListChildBuilder(
        ListChildValueNotifier(context, path, defaultValue), builder);
  }
}

class PathAndValue<T> {
  String path;
  T value;

  PathAndValue(this.path, this.value);
}

abstract class SubscribedNotifier<T> extends ValueNotifier<T> {
  void Function() removeFromCache;
  void Function() cancel;
  int refCount = 0;

  SubscribedNotifier(T defaultValue, this.removeFromCache)
      : super(defaultValue);

  @override
  void addListener(listener) {
    refCount++;
    super.addListener(listener);
  }

  @override
  void removeListener(listener) {
    refCount--;
    super.removeListener(listener);
    if (refCount == 0) {
      removeFromCache();
      cancel();
    }
  }
}
