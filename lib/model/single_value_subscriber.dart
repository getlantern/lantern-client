import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';
import 'model_event_channel.dart';

/// A ValueNotifier that updates a single value based on subscribing to a path
/// in the database.
class SubscribedSingleValueNotifier<T> extends SubscribedNotifier<T> {
  SubscribedSingleValueNotifier(
      path, T defaultValue, ModelEventChannel channel, void removeFromCache(),
      {bool details, T deserialize(Uint8List serialized)})
      : super(defaultValue, removeFromCache) {
    cancel = channel.subscribe(path, details: details,
        onUpdates: (Iterable<PathAndValue<T>> updates) {
      value = updates.length > 0 ? updates.last.value : null;
    }, onDeletes: (Iterable<String> deletes) {
      value = null;
    }, deserialize: deserialize);
  }
}

/// A ValueListenableBuilder that obtains its single value by subscribing to a
/// path in the database.
class SubscribedSingleValueBuilder<T> extends ValueListenableBuilder<T> {
  SubscribedSingleValueBuilder(
      String path, ValueNotifier<T> notifier, ValueWidgetBuilder<T> builder)
      : super(valueListenable: notifier, builder: builder);

  @override
  _SubscribedSingleValueBuilderState createState() =>
      _SubscribedSingleValueBuilderState<T>();
}

class _SubscribedSingleValueBuilderState<T>
    extends State<ValueListenableBuilder<T>> {
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
