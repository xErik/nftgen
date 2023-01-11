import 'dart:io';

class Cache {
  final Map<String, File> _cache = {};
  final sep = Platform.pathSeparator;

  void _addCache(String key, String type, String value, String layersDir,
      List confLayers) {
    late final File file;

    for (var confLayer in confLayers) {
      final String layerName = confLayer['name'] as String;
      if (layerName == type) {
        final layerDir = confLayer['directory'] as String;
        final nftFiles = Map<String, int>.from(confLayer['weights']).keys;
        final nftFile =
            nftFiles.toList().firstWhere((e) => e.startsWith(value));
        final layerPath = layersDir + sep + layerDir + sep + nftFile;
        file = File(layerPath);
        break;
      }
    }

    _cache.addAll({key: file});
    // keyList.shuffle(rnd);
  }

  File getFile(String type, String value, String layersDir, List confLayers) {
    final key = type + value;
    if (_cache.containsKey(key) == false) {
      _addCache(key, type, value, layersDir, confLayers);
    }
    return _cache[key]!;
  }
}
