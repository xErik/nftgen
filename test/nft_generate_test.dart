import 'dart:io';

import 'package:nft_generate/src/config.dart';
import 'package:nft_generate/src/shared/io.dart';
import 'package:nft_generate/src/nft.dart';
import 'package:test/test.dart';

void main() {
  test('generateConfigAndNftFromLayers', () {
    final sep = Platform.pathSeparator;
    final assets = Directory('assets');
    final layersDir = Directory('${assets.path}${sep}layers');
    final genImagesDir = Directory('${assets.path}${sep}images');
    final genMetaDir = Directory('${assets.path}${sep}meta');

    final Map<String, dynamic> config = Config.generate(layersDir, factor: 3);
    final configFile = File('${assets.path}${sep}config_generated.json');
    Io.writeJson(configFile, config);

    Nft.generate(configFile, layersDir, genImagesDir, genMetaDir);
  });
}
