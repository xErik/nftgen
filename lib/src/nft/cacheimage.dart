// import 'dart:io';

// import 'package:image/image.dart';
// import 'package:path/path.dart';

// class CacheImage {
//   final Map<String, Image> _cache = {};

//   Future<void> _addCache(String filePath) async {
//     final bytes = await decodeImageFile(filePath);
//     if (bytes == null) {
//       PathException('File not found: $filePath');
//     }
//     _cache.addAll({filePath: bytes!});
//   }

//   Future<Image> getImage(File file) async {
//     final path = file.path;
//     if (_cache.containsKey(path) == false) {
//       await _addCache(path);
//     }
//     return _cache[path]!;
//   }
// }

import 'dart:io';
import 'dart:ui';

// import 'package:image/image.dart';
import 'package:path/path.dart';

class CacheImage {
  final Map<String, Image> _cache = {};

  Future<void> _addCache(String filePath) async {
    var codec = await instantiateImageCodec(File(filePath).readAsBytesSync());
    var frame = await codec.getNextFrame();
    _cache.addAll({filePath: frame.image});
  }

  Future<Image> getImage(File file) async {
    final path = file.path;
    if (_cache.containsKey(path) == false) {
      await _addCache(path);
    }
    return _cache[path]!;
  }
}
