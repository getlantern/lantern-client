import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'model.dart';
import 'model_event_channel.dart';

/// A ValueNotifier that maintains a list of values based on updates from the
/// the database. It relies on nested ListChildValueNotifiers to handle updates
/// to individual values and only updates the whole list if new values were
/// added or old values were removed. Thus, it is optimized for use within
/// ListViews.
class SubscribedListNotifier<T>
    extends SubscribedNotifier<ChangeTrackingList<T>> {
  SubscribedListNotifier(
      path, ModelEventChannel channel, void removeFromCache(),
      {bool details,
      int compare(String key1, String key2),
      deserialize(Uint8List serialized)})
      : super(ChangeTrackingList(compare != null ? compare : sortNormally),
            removeFromCache) {
    cancel = channel.subscribe<T>(path, details: details,
        onUpdates: (Iterable<PathAndValue<T>> updates) {
      value.clearPaths();
      updates.forEach((u) {
        if (value.map.containsKey(u.path)) {
          value.updatedPaths.add(u.path);
        } else {
          value.newPaths.add(u.path);
        }
        value.map[u.path] = u.value;
      });
      notifyListeners();
    }, onDeletes: (Iterable<String> deletes) {
      value.clearPaths();
      deletes.forEach((path) {
        value.deletedPaths.add(path);
        value.map.remove(path);
      });
      notifyListeners();
    }, deserialize: deserialize);
  }
}

class ChangeTrackingList<T> {
  SplayTreeMap<String, T> map;
  var newPaths = <String>[];
  var updatedPaths = <String>[];
  var deletedPaths = <String>[];

  ChangeTrackingList(int compare(String key1, String key2)) {
    this.map = SplayTreeMap<String, T>(compare);
  }

  void clearPaths() {
    newPaths.clear();
    updatedPaths.clear();
    deletedPaths.clear();
  }
}

/// A ValueListenableBuilder that obtains a list of values by subscribing to a
/// path in the database.
class SubscribedListBuilder<T>
    extends ValueListenableBuilder<ChangeTrackingList<T>> {
  SubscribedListBuilder(
      String path,
      ValueNotifier<ChangeTrackingList<T>> notifier,
      ValueWidgetBuilder<ChangeTrackingList<T>> builder)
      : super(valueListenable: notifier, builder: builder);

  @override
  _SubscribedListBuilderState createState() => _SubscribedListBuilderState<T>();
}

class _SubscribedListBuilderState<T>
    extends State<ValueListenableBuilder<ChangeTrackingList<T>>> {
  ChangeTrackingList<T> value;
  var _childNotifiers = HashMap<String, List<ListChildValueNotifier<T>>>();

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  @override
  void didUpdateWidget(
      ValueListenableBuilder<ChangeTrackingList<T>> oldWidget) {
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
        newMap.updatedPaths.isNotEmpty || newMap.deletedPaths.isNotEmpty;
    if (!pathsChanged) {
      // we can take the optimized path and just notify the children
      newMap.updatedPaths.forEach((path) {
        var newValue = newMap.map[path];
        _childNotifiers[path]?.forEach((notifier) {
          notifier.value = newValue;
        });
      });
      return;
    }

    // Need to update the whole thing
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

class ListChildValueNotifier<T> extends ValueNotifier<T> {
  ListChildValueNotifier(BuildContext context, String path, T defaultValue)
      : super(defaultValue) {
    var childNotifiers = context
        .findAncestorStateOfType<_SubscribedListBuilderState>()
        ._childNotifiers;
    var notifiers = childNotifiers[path] ?? <ListChildValueNotifier<T>>[];
    notifiers.add(this);
    childNotifiers[path] = notifiers;
  }
}

/// A ValueListenableBuilder that obtains updates by subscribing to a specific
/// path in a containing SplayTreeMapBuilder.
class ListChildBuilder<T> extends ValueListenableBuilder<T> {
  ListChildBuilder(ValueNotifier<T> notifier, ValueWidgetBuilder<T> builder)
      : super(valueListenable: notifier, builder: builder);

  @override
  _MapChildBuilderState createState() => _MapChildBuilderState<T>();
}

class _MapChildBuilderState<T> extends State<ListChildBuilder<T>> {
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
    context
        .findAncestorStateOfType<_SubscribedListBuilderState>()
        ._childNotifiers
        ?.remove(this.widget.valueListenable);
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

int sortNormally(String key1, String key2) {
  return key1.compareTo(key2);
}

int sortReversed(String key1, String key2) {
  return key2.compareTo(key1);
}
