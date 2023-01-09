import 'dart:math';

class Cache {
  final Random _rnd;
  final Map<String, List<String>> _cache = {};

  Cache(this._rnd);

  void _addCache(String key, Map<String, int> weights) {
    final List<String> keyList = [];
    for (var entry in weights.entries) {
      for (var i = 0; i < entry.value; i++) {
        keyList.add(entry.key);
      }
    }
    _cache.addAll({key: keyList});
    // keyList.shuffle(rnd);
  }

  String getRandomWeight(String key, Map<String, int> weights) {
    if (_cache.containsKey(key) == false) {
      _addCache(key, weights);
    }
    _cache[key]!.shuffle(_rnd);
    return _cache[key]!.elementAt(0);
  }
}
