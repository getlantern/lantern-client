import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'model_event_channel.dart';

abstract class Model {
  MethodChannel methodChannel;
  ModelEventChannel _updatesChannel;
  Map<String, SubscribedValueNotifier> _subscribedValueNotifiers = HashMap();

  Model(String name) {
    methodChannel = MethodChannel("${name}_method_channel");
    _updatesChannel = ModelEventChannel("${name}_event_channel");
  }

  Future<void> put<T>(String path, T value) async {
    methodChannel.invokeMethod('put', <String, dynamic>{
      "path": path,
      "value": value,
    });
  }

  Future<List<T>> getRange<T>(String path, int start, int count) async {
    var intermediate =
        await methodChannel.invokeMethod('getRange', <String, dynamic>{
      "path": path,
      "start": start,
      "count": count,
    });
    var result = List<T>();
    intermediate.forEach((element) => result.add(element as T));
    return result;
  }

  Future<List<T>> getRangeDetails<T>(
      String path, String detailsPrefix, int start, int count) async {
    var intermediate =
        await methodChannel.invokeMethod('getRangeDetails', <String, dynamic>{
      "path": path,
      "detailsPrefix": detailsPrefix,
      "start": start,
      "count": count,
    });
    var result = List<T>();
    intermediate.forEach((element) => result.add(element as T));
    return result;
  }

  Future<List<ValueNotifier<T>>> getRangeDetailNotifiers<T>(String path,
      String detailsPrefix, int start, int count, T defaultValue) async {
    var list = await getRange(path, start, count);
    return Future.value(list.map((e) {
      var detailsPath = "$detailsPrefix/$e";
      return buildValueNotifier(detailsPath, defaultValue);
    }).toList());
  }

  ValueNotifier<T> buildValueNotifier<T>(String path, T defaultValue, {T deserialize(Uint8List serialized)}) {
    SubscribedValueNotifier<T> result = _subscribedValueNotifiers[path];
    if (result == null) {
      result = SubscribedValueNotifier(path, defaultValue, _updatesChannel, deserialize: deserialize);
      _subscribedValueNotifiers[path] = result;
    }
    return result;
  }

  ValueListenableBuilder<T> subscribedBuilder<T>(String path,
      {@required T defaultValue, @required ValueWidgetBuilder<T> builder, T deserialize(Uint8List serialized)}) {
    var notifier = buildValueNotifier(path, defaultValue, deserialize: deserialize);
    return SubscribedBuilder<T>(path, notifier, builder);
    // TODO: provide a mechanism for canceling subscriptions
  }
}

class SubscribedValueNotifier<T> extends ValueNotifier<T> {
  void Function() cancel;

  SubscribedValueNotifier(
      String path, T defaultValue, ModelEventChannel channel,
      {T deserialize(Uint8List serialized)})
      : super(defaultValue) {
    cancel = channel.subscribe(path, onNewValue: (dynamic newValue) {
      value = newValue as T;
    }, deserialize: deserialize);
  }
}

class SubscribedBuilder<T> extends ValueListenableBuilder<T> {
  final SubscribedValueNotifier<T> _notifier;
  final String _path;

  SubscribedBuilder(this._path, this._notifier, ValueWidgetBuilder<T> builder)
      : super(valueListenable: _notifier, builder: builder);

  @override
  _SubscribedBuilderState createState() => _SubscribedBuilderState<T>();
}

class _SubscribedBuilderState<T> extends State<ValueListenableBuilder<T>> {
  T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder<T> oldWidget) {
    if (oldWidget.valueListenable != widget.valueListenable) {
      oldWidget.valueListenable.removeListener(_valueChanged);
      value = widget.valueListenable.value;
      widget.valueListenable.addListener(_valueChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.valueListenable.removeListener(_valueChanged);
    // TODO: we should only cancel if we're the last one
    // (widget.valueListenable as SubscribedValueNotifier).cancel();
    super.dispose();
  }

  void _valueChanged() {
    setState(() {
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Container();
    }
    return widget.builder(context, value, widget.child);
  }
}
