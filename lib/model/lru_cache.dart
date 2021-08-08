// based on https://github.com/platelk/dcache
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef LoadFunc<K, V> = Future<V> Function(K key);

class LRUCache<K, V> {
  final _entries = HashMap<K, CacheEntry<K, V>>();
  final int _limit;
  final LoadFunc<K, V> _load;

  LRUCache(this._limit, this._load);

  ValueListenable<CachedValue<V>> get(K key) {
    var entry = _entries[key];
    if (entry == null) {
      entry = CacheEntry(key);
      _load(key).then((v) {
        entry!.value.value = CachedValue(loading: false, value: v);
      }).catchError((e) {
        entry!.value.value = CachedValue(loading: false, error: e);
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
  K key;
  ValueNotifier<CachedValue<V>> value = ValueNotifier(CachedValue());
  DateTime lastUse = DateTime.now();

  CacheEntry(this.key);

  void updateUseTime() {
    lastUse = DateTime.now();
  }
}

class CachedValue<V> {
  final bool loading;
  final V? value;
  final Object? error;

  CachedValue({this.loading = true, this.value, this.error});
}
