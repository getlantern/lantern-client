import '../utils/common.dart';

/// A ValueNotifier that updates a single value based on subscribing to a path
/// in the database.
class SubscribedSingleValueNotifier<T> extends SubscribedNotifier<T?> {
  SubscribedSingleValueNotifier(
    path,
    T? defaultValue,
    ModelEventChannel channel,
    void Function() removeFromCache, {
    bool details = false,
    T Function(Uint8List serialized)? deserialize,
  }) : super(defaultValue, removeFromCache) {
    void onChanges(Map<String, T> updates, Iterable<String> deletions) {
      if (deletions.isNotEmpty) {
        value = null;
      } else {
        value = updates.isNotEmpty ? updates.values.first : null;
      }
    }

    cancel = channel.subscribe(
      path,
      details: details,
      onChanges: onChanges,
      deserialize: deserialize,
    );
  }
}

/// A ValueListenableBuilder that obtains its single value by subscribing to a
/// path in the database.
class SubscribedSingleValueBuilder<T> extends ValueListenableBuilder<T?> {
  SubscribedSingleValueBuilder(
    String path,
    ValueNotifier<T?> notifier,
    ValueWidgetBuilder<T> builder,
  ) : super(
          valueListenable: notifier,
          builder: (BuildContext context, T? value, Widget? child) =>
              value == null ? const SizedBox() : builder(context, value, child),
        );

  @override
  _SubscribedSingleValueBuilderState createState() =>
      _SubscribedSingleValueBuilderState<T>();
}

class _SubscribedSingleValueBuilderState<T>
    extends State<ValueListenableBuilder<T?>> {
  T? value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder<T?> oldWidget) {
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
    return widget.builder(context, value, widget.child);
  }
}
