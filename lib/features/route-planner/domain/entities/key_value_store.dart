class KeyValueStore<K, V> {
  Map<K, V> _store = {};

  void set(K key, V value) {
    _store[key] = value;
  }

  V? get(K key) {
    return _store[key];
  }

  void remove(K key) {
    _store.remove(key);
  }

  Map<K, V> getAll() {
    return _store;
  }
}