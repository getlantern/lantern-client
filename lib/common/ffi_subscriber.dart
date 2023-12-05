import 'common.dart';
import 'common_desktop.dart';

extension BoolParsing on String {
  bool parseBool() {
    return this.toLowerCase() == 'true';
  }
}

class FfiValueNotifier<T> extends SubscribedNotifier<T?> {
  FfiValueNotifier(
    Pointer<Utf8> Function() ffiFunction,
    T? defaultValue,
    void Function() removeFromCache, {
    bool details = false,
    T Function(Uint8List serialized)? deserialize,
  }) : super(defaultValue, removeFromCache) {
    if (defaultValue is int?) {
      value = null;
      //value = int.parse(ffiFunction().toDartString()) as T?;
    } else if (defaultValue is String) {
      value = ffiFunction().toDartString() as T?;
    } else {
      value = ffiFunction().toDartString().parseBool() as T?;
    }
    cancel = () => {};
  }
}

/// A ValueListenableBuilder that obtains its single value by subscribing to a
/// path in the database.
class FfiValueBuilder<T> extends ValueListenableBuilder<T?> {
  FfiValueBuilder(
    String path,
    ValueNotifier<T?> notifier,
    ValueWidgetBuilder<T> builder,
  ) : super(
          valueListenable: notifier,
          builder: (BuildContext context, T? value, Widget? child) =>
              value == null ? const SizedBox() : builder(context, value, child),
        );

  @override
  _FfiValueBuilderState createState() =>
      _FfiValueBuilderState<T>();
}

class _FfiValueBuilderState<T>
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
