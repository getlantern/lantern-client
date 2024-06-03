import 'dart:collection';

import 'common.dart';
import 'common_desktop.dart';

class FfiListNotifier<T> extends SubscribedNotifier<ChangeTrackingList<T>> {
  FfiListNotifier(
    path,
    Pointer<Utf8> Function() ffiFunction,
    T Function(Map<String, dynamic> json) fromJsonModel,
    void Function() removeFromCache, {
    bool details = false,
    int Function(String key1, String key2)? compare,
    T Function(Uint8List serialized)? deserialize,
  }) : super(ChangeTrackingList(compare ?? sortNormally), removeFromCache) {
    value.clearPaths();
    var result = jsonDecode(ffiFunction().toDartString());
    if (result is List<dynamic>) {
      for (var item in result) {
        var id = item['id'] ?? item['name'];
        value.map[id] = fromJsonModel(item) as T;
      }
    } else if (result is Map<String, dynamic>) {
      for (var key in result.keys) {
        value.map[key] = fromJsonModel(result) as T;
      }
    }
    cancel = () => {};
  }
}

/// A ValueListenableBuilder that obtains a list of values by subscribing to a
/// path in the database.
class FfiListBuilder<T> extends ValueListenableBuilder<ChangeTrackingList<T>> {
  FfiListBuilder(
    String path,
    ValueNotifier<ChangeTrackingList<T>> notifier,
    ValueWidgetBuilder<ChangeTrackingList<T>> builder,
  ) : super(valueListenable: notifier, builder: builder);

  @override
  _FfiListBuilderState createState() => _FfiListBuilderState<T>();
}

class _FfiListBuilderState<T>
    extends State<ValueListenableBuilder<ChangeTrackingList<T>>> {
  late ChangeTrackingList<T> value;
  final _childNotifiers = HashMap<String, ValueNotifier<T?>>();

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(
    ValueListenableBuilder<ChangeTrackingList<T>> oldWidget,
  ) {
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
    var newMap = widget.valueListenable.value;
    var pathsChanged =
        newMap.newPaths.isNotEmpty || newMap.deletedPaths.isNotEmpty;
    var missingChildNotifier = false;
    if (!pathsChanged) {
      // we can take the optimized path and just notify the children
      newMap.updatedPaths.forEach((path) {
        var newValue = newMap.map[path];
        var foundChildNotifier = false;
        var notifier = _childNotifiers[path];
        if (notifier != null) {
          notifier.value = newValue;
          foundChildNotifier = true;
        }
        missingChildNotifier = missingChildNotifier || !foundChildNotifier;
      });
      if (!missingChildNotifier) {
        // Only stop processing if we had notifiers for every updated value.
        // If not, we'll fall through and update the whole list.
        return;
      }
    }

    // Need to update the whole thing
    setState(() {
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
