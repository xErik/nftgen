@Timeout(Duration(minutes: 5))

import 'dart:io';

import 'package:nftgen/config.dart';
import 'package:nftgen/rarity.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/nft.dart';
import 'package:test/test.dart';

void main() {
  test('generateConfigAndNftFromLayers', () async {
    final sep = Platform.pathSeparator;
    final project = Directory('project');
    // For CONFIG and NFT
    final layerDir = Directory('${project.path}${sep}layer');
    final imageDir = Directory('${project.path}${sep}image');
    final metaDir = Directory('${project.path}${sep}meta');
    // To ANALYZE NFT
    final csvNft = File('${project.path}${sep}rarity_nft.csv');
    final csvLayers = File('${project.path}${sep}rarity_layers.csv');

    // Write config JSON based on layers directory

    final Map<String, dynamic> config =
        Config.generate('Your NFT', layerDir, factor: 3);
    final configFile = File('${project.path}${sep}config_gen.json');
    Io.writeJson(configFile, config);

    // Generate metadata based on config JSON

    Nft.generateMeta(configFile, metaDir);

    // Generate NFTs based on config JSON

    await Nft.generateNft(configFile, layerDir, imageDir, metaDir);

    // Analyze generated NFT metadata and save it

    final nftAnalysis = Rarity.nfts(metaDir);
    final layersAnalysis = Rarity.layers(metaDir);
    Io.writeCsv(nftAnalysis, csvNft);
    Io.writeCsv(layersAnalysis, csvLayers);

    // Update metadata json with CID code given in config

    Config.updateCidMetadata(configFile, metaDir,
        cidSearch: "<-- Your CID Code-->", cidReplace: "NEW-CID");
  });
}
