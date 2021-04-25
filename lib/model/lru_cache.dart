// based on https://github.com/platelk/dcache
import 'dart:async';
import 'dart:collection';

typedef LoadFunc<K, V> = Future<V> Function(K key);

class LRUCache<K, V> {
  final _entries = HashMap<K, CacheEntry<K, V>>();
  final int _limit;
  final LoadFunc<K, V> _load;

  LRUCache(this._limit, this._load);

  Future<V> get(K key) {
    var entry = _entries[key];
    entry ??= CacheEntry(key);
    entry.value ??= _load(key);
    entry.updateUseTime();
    var numEntriesToRemove = _entries.length - _limit;
    if (numEntriesToRemove > 0) {
      var values = _entries.values.toList(growable: false);
      values.sort((a, b) => a.lastUse.compareTo(b.lastUse));
      values.take(numEntriesToRemove).forEach((element) {
        _entries.remove(element.key);
      });
    }
    return entry.value!;
  }
}

class CacheEntry<K, V> {
  K key;
  Future<V>? value;
  DateTime lastUse = DateTime.now();

  CacheEntry(this.key);

  void updateUseTime() {
    lastUse = DateTime.now();
  }
}
