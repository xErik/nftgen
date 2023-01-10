import 'dart:ffi';
import 'dart:io';

import 'package:nftgen/src/config.dart';
import 'package:nftgen/src/nft.dart';
import 'package:nftgen/src/rarity.dart';
import 'package:nftgen/src/shared/io.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    usage();
    return;
  }

  if (args[0] == "config") {
    final layersDir = Directory(args[1]);
    final configFile = File(args[2]);
    final factor = args.length >= 4 ? double.parse(args[3]) : 3.0;
    final order = args.length >= 5 ? args[4].split(',') : <String>[];
    final config = Config.generate(layersDir, factor: factor, order: order);
    Io.writeJson(configFile, config);
  } else if (args[0] == "nft") {
    final layersDir = Directory(args[1]);
    final configFile = File(args[2]);
    final genImagesDir = Directory(args[3]);
    final genMetaDir = Directory(args[4]);
    final metaOnly =
        args.length >= 6 ? args[5].toLowerCase() == 'metaonly' : false;

    Nft.generate(configFile, layersDir, genImagesDir, genMetaDir,
        metaOnly: metaOnly);
  } else if (args[0] == "cid") {
    final configFile = File(args[1]);
    final genMetaDir = Directory(args[2]);
    final cid = args.length >= 4 ? args[3] : '';
    final cidReplace = args.length >= 5 ? args[4] : '';
    Config.updateCidMetadata(configFile, genMetaDir,
        cidReplace: cid, cidSearch: cidReplace);
  } else if (args[0] == 'rarity') {
    final metaDir = Directory(args[1]);
    final csvNftFile = File(args[2]);
    final csvLayersFile = File(args[3]);
    final imgNftFile = '${args[2].replaceAll('.csv', '')}.png';
    final imgLayersFile = '${args[3].replaceAll('.csv', '')}.png';

    List<MapEntry<String, double>> sortedNft = Rarity.nfts(metaDir);
    List<MapEntry<String, double>> sortedAttr = Rarity.layers(metaDir);

    await Rarity.drawChart(imgNftFile, sortedNft, 'NFTs: high = high rarity');
    await Rarity.drawChart(
        imgLayersFile, sortedAttr, 'Attributes: low = high rarity');

    Io.writeCsv(sortedNft, csvNftFile);
    Io.writeCsv(sortedAttr, csvLayersFile);

    print('Rarity NFTs: ${csvNftFile.path} (large = rare)');
    print('Rarity Layers: ${csvLayersFile.path} (small = rare)');
  } else {
    usage();
  }
}

void usage() {
  print('USAGE\n');

  print('* Generate a config-json file:\n');
  print(
      "  nftgen config <IN-LAYERS-DIR> <OUT-CONFIG-FILE> [<WEIGHT-FACTOR>:3.0]");

  print('\n* Generate NFTs based on a config-json file:\n');
  print(
      "  nftgen nft <IN-CONFIG-FILE> <IN-LAYERS-DIR> <OUT-IMAGE-DIR> <OUT-META-DIR> [metaOnly]");

  print(
      '\n* Add CID code read from config or given as parameter to metadata files:\n');
  print("  nftgen cid <IN-CONFIG-FILE> <OUT-META-DIR> [<CID>, <CID-REPLACE>]");

  print("\n* Generate rarity reports basd on metadata directory:\n");
  print(
      "  nftgen rarity <IN-META-DIR> <OUT-RARITY-NFT.CSV> <OUT-RARITY-LAYERS.CSV>");

  // ---

  print("\nEXAMPLES\n");
  print(
      "* Generate a config with equal weight distribution and ordered layers:\n");
  print(
      '  nftgen config .\\assets\\layers\\ .\\assets\\config_gen.json 0.0 "Background,Eyeball,Eye color,Iris,Shine,Bottom lid,Top lid"');

  print("\n* Generate NFTs based on a config:\n");
  print(
      "  nftgen nft .\\assets\\layers\\ .\\assets\\config_gen.json  .\\assets\\images\\ .\\assets\\meta\\");

  print("\n* Generate NFTs based on a config but METADATA only:\n");
  print(
      "  nftgen nft .\\assets\\layers\\ .\\assets\\config_gen.json  .\\assets\\images\\ .\\assets\\meta\\ metaonly");

  print("\n* Add CID code given as parameter to config and metadata:\n");
  print(
      "  nftgen cid .\\assets\\config_gen.json  .\\assets\\meta\\ NEW-CID-CODE OLD-CID-CODE");

  print("\n* Replace CID with CID-REPLACE read from config to metadata:\n");
  print("  nftgen cid .\\assets\\config_gen.json  .\\assets\\meta\\");

  print("\n* Generate rarity reports basd on metadata directory:\n");
  print(
      "  nftgen rarity .\\assets\\meta\\ .\\assets\\rarity_nft.csv .\\assets\\rarity_layers.csv");
}
