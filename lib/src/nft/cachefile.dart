import 'dart:io';

import 'package:nftgen/framework/projectmodel.dart';

class CacheFile {
  final Map<String, File> _cache = {};
  final sep = Platform.pathSeparator;

  void _addCache(String key, String type, String value, String layersDir,
      List<ProjectLayerModel> confLayers) {
    late final File file;

    for (var confLayer in confLayers) {
      final String layerName = confLayer.name;
      if (layerName == type) {
        final Directory layerDir = confLayer.directory;
        final nftFiles = Map<String, int>.from(confLayer.weights).keys;
        final nftFile =
            nftFiles.toList().firstWhere((e) => e.startsWith(value));
        final layerPath = layersDir + sep + layerDir.path + sep + nftFile;
        file = File(layerPath);
        break;
      }
    }

    _cache.addAll({key: file});
  }

  File getFile(String type, String value, String layersDir,
      List<ProjectLayerModel> confLayers) {
    final key = type + value;
    if (_cache.containsKey(key) == false) {
      _addCache(key, type, value, layersDir, confLayers);
    }
    return _cache[key]!;
  }
}
