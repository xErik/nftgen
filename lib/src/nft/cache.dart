import 'dart:math';

class CacheLayerFileWeights {
  final Random _rnd;
  final Map<String, List<String>> _cache = {};

  CacheLayerFileWeights(this._rnd);

  void _addCache(String key, Map<String, int> weights) {
    final List<String> keyList = [];
    for (var entry in weights.entries) {
      for (var i = 0; i < entry.value; i++) {
        keyList.add(entry.key);
      }
    }
    _cache.addAll({key: keyList});
  }

  String getLayerFileByRandomWeight(String key, Map<String, int> weights) {
    if (_cache.containsKey(key) == false) {
      _addCache(key, weights);
    }
    return _cache[key]!.elementAt(_rnd.nextInt(_cache[key]!.length));
  }
}
