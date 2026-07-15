/// In-memory cache mapping request keys to results, with TTL-based expiry.
class MemoryCache<K, V> {
  MemoryCache({
    this.ttl = defaultTtl,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const Duration defaultTtl = Duration(minutes: 5);

  /// An entry is served for strictly less than [ttl] after being stored;
  /// at exactly [ttl] it is treated as expired and evicted on read.
  final Duration ttl;
  final DateTime Function() _clock;
  final _entries = <K, _CacheEntry<V>>{};

  /// Returns the cached value for [key], or null if absent or expired.
  V? get(K key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_clock().difference(entry.storedAt) >= ttl) {
      _entries.remove(key);
      return null;
    }
    return entry.value;
  }

  void set(K key, V value) => _entries[key] = _CacheEntry(value, _clock());

  void invalidate(K key) => _entries.remove(key);

  void clear() => _entries.clear();
}

class _CacheEntry<V> {
  _CacheEntry(this.value, this.storedAt);

  final V value;
  final DateTime storedAt;
}
