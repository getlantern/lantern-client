// based on https://github.com/platelk/dcache
import 'dart:collection';

import 'package:lantern/features/replica/common.dart';

import 'common.dart';

typedef LoadFunc<K, V> = Future<V> Function(K key);

class LRUCache<K, V> {
  final _entries = HashMap<K, CacheEntry<K, V>>();
  final int _limit;
  final LoadFunc<K, V> _load;

  LRUCache(this._limit, this._load);

  ValueListenable<CachedValue<V>> get(K key) {
    var entry = _entries[key];
    if (entry == null) {
      var future = _load(key);
      entry = CacheEntry(key: key, future: future);
      future.then((v) {
        entry!.value.value =
            CachedValue(future: future, loading: false, value: v);
      }).catchError((e) {
        logger.e(e);
        entry!.value.value =
            CachedValue(future: future, loading: false, error: e);
        _entries.remove(entry.key);
      });
      _entries[key] = entry;
    }
    entry.updateUseTime();
    var numEntriesToRemove = _entries.length - _limit;
    if (numEntriesToRemove > 0) {
      var values = _entries.values.toList(growable: false);
      values.sort((a, b) => a.lastUse.compareTo(b.lastUse));
      values.take(numEntriesToRemove).forEach((element) {
        _entries.remove(element.key);
      });
    }
    return entry.value;
  }
}

class CacheEntry<K, V> {
  final K key;
  late ValueNotifier<CachedValue<V>> value;
  DateTime lastUse = DateTime.now();

  CacheEntry({required this.key, required Future<V> future}) {
    value = ValueNotifier(CachedValue(future: future));
  }

  void updateUseTime() {
    lastUse = DateTime.now();
  }
}

/// An asynchronously loaded value cached in an LRU cache. CachedValues are
/// immutable.
///
/// [loading] indicates if the value is still asynchronously loading
/// [value] will have the loaded value if loading completed successfully
/// [error] if loading fails, this contains the error encountered
///
class CachedValue<V> {
  /// a future that can be used to watch for completion of the value loading
  Future<V> future;

  /// indicates if the value is still asynchronously loading
  final bool loading;

  /// will have the loaded value if loading completed successfully
  final V? value;

  /// will contain the error if loading failed
  final Object? error;

  CachedValue({
    required this.future,
    this.loading = true,
    this.value,
    this.error,
  });
}
