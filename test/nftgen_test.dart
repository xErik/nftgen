import 'dart:io';

import 'package:nftgen/config.dart';
import 'package:nftgen/rarity.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/nft.dart';
import 'package:test/test.dart';

void main() {
  test('generateConfigAndNftFromLayers', () {
    final sep = Platform.pathSeparator;
    final project = Directory('project');
    // For CONFIG and NFT
    final layersDir = Directory('${project.path}${sep}layers');
    final imagesDir = Directory('${project.path}${sep}images');
    final metaDir = Directory('${project.path}${sep}meta');
    // For ANALYZE NFT
    final csvNft = File('${project.path}${sep}rarity_nft.csv');
    final csvLayers = File('${project.path}${sep}rarity_layers.csv');

    // Write config JSON based on layers directory

    final Map<String, dynamic> config =
        Config.generate('Your NFT', layersDir, factor: 3);
    final configFile = File('${project.path}${sep}config_generated.json');
    Io.writeJson(configFile, config);

    // Generate NFTs based on config JSON

    Nft.generateNft(configFile, layersDir, imagesDir, metaDir);

    // Analyze generated NFT metadata and save it

    final nftAnalysis = Rarity.nfts(metaDir);
    final layersAnalysis = Rarity.layers(metaDir);
    Io.writeCsv(nftAnalysis, csvNft);
    Io.writeCsv(layersAnalysis, csvLayers);

    // Update metadata json with CID code given in config

    Config.updateCidMetadata(configFile, metaDir);
  });
}
