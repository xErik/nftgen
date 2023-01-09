import 'dart:io';

import 'package:nft_generate/src/config.dart';
import 'package:nft_generate/src/nft.dart';
import 'package:nft_generate/src/shared/io.dart';

void main(List<String> args) {
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

    Nft.generate(configFile, layersDir, genImagesDir, genMetaDir);
  } else if (args[0] == "cid") {
    final configFile = File(args[1]);
    final genMetaDir = Directory(args[2]);
    final cid = args.length >= 4 ? args[3] : '';
    final cidReplace = args.length >= 5 ? args[4] : '';
    Config.setCidMetadata(configFile, genMetaDir,
        cidReplace: cid, cidSearch: cidReplace);
  } else {
    usage();
  }
}

void usage() {
  print('USAGE\n');

  print(' * Generate a config-json file:\n');
  print(
      " nft_generate config <IN-LAYERS-DIR> <OUT-CONFIG-FILE> [<WEIGHT-FACTOR>:3.0]");

  print('\n * Generate NFTs based on a config-json file:\n');
  print(
      " nft_generate nft <IN-CONFIG-FILE> <IN-LAYERS-DIR> <OUT-IMAGE-DIR> <OUT-META-DIR>");

  print(
      '\n * Add CID code read from config or given as parameter to metadata files:\n');
  print(
      " nft_generate cid <IN-CONFIG-FILE> <OUT-META-DIR> [<CID>, <CID-REPLACE>]");

  print("\nEXAMPLES\n");
  print(
      " * Generate a config with equal weight distribution and ordered layers:\n");
  print(
      ' nft_generate config .\\assets\\layers\\ .\\assets\\config_gen.json 0.0 "Background,Eyeball,Eye color,Iris,Shine,Bottom lid,Top lid"');

  print("\n * Generate NFTs based on a config:\n");
  print(
      " nft_generate nft .\\assets\\layers\\ .\\assets\\config_gen.json  .\\assets\\images\\ .\\assets\\meta\\");

  print("\n * Add CID code given as parameter to config and metadata:\n");
  print(
      " nft_generate cid .\\assets\\config_gen.json  .\\assets\\meta\\ NEW-CID-CODE OLD-CID-CODE");

  print("\n * Replace CID with CID-REPLACE read from config to metadata:\n");
  print(" nft_generate cid .\\assets\\config_gen.json  .\\assets\\meta\\");
}
