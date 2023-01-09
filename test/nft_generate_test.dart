import 'dart:io';

import 'package:nft_generate/nft_generate.dart';
import 'package:test/test.dart';

void main() {
  test('generateConfigFromLayers', () {
    final sep = Platform.pathSeparator;
    final assets = Directory('assets');
    final layersDir = Directory('${assets.path}${sep}layers');
    final genImagesDir = Directory('${assets.path}${sep}images');
    final genMetaDir = Directory('${assets.path}${sep}meta');

    final Map<String, dynamic> config = genConfig(layersDir, 3);

    final configFile = File('${assets.path}${sep}config_generated.json');

    writeJson(configFile, config);

    genNfts(configFile, layersDir, genImagesDir, genMetaDir);
  });
}
