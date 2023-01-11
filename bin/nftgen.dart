import 'dart:io';

import 'package:nftgen/config.dart';
import 'package:nftgen/nft.dart';
import 'package:nftgen/rarity.dart';
import 'package:nftgen/src/shared/io.dart';

/// General command template:
/// nftgen <PROJECT-DIR> <COMMAND> [PARAMETERS]
///
/// Commandwill assume local direcrory `project`:
/// nftgen <COMMAND> [PARAMETERS]
void main(List<String> args) async {
  if (args.isEmpty) {
    usage();
    return;
  }

  int indexShift = 0;
  final sep = Platform.pathSeparator;
  var projectDir = Directory(args[0]);
  late final String command;
  late final Map<String, dynamic> project;

  if (projectDir.existsSync()) {
    indexShift = 1;
    command = args[0 + indexShift];
    project = Io.readJson(File("${projectDir.path}${sep}project.json"));
    print('Project directory set to: ${projectDir.path}');
  } else {
    command = args[0 + indexShift];
    projectDir = Directory("project");
    project = Io.readJson(File("${projectDir.path}${sep}project.json"));
    print('Project directory set to: ${projectDir.path}');
  }

  final configFile = File(projectDir.path + sep + project['configFile']);
  // Map<String, dynamic> config = {};

  late final Directory metaDir;
  late final Directory layerDir;
  late final Directory imageDir;

  late final File csvNftFile;
  late final File csvLayersFile;
  late final File pngNftFile;
  late final File pngLayersFile;

  if (Directory(configFile.path).existsSync()) {
    // config = Io.readJson(configFile);

    metaDir = Directory(projectDir.path + sep + project['metaDir']);
    layerDir = Directory(projectDir.path + sep + project['layerDir']);
    imageDir = Directory(projectDir.path + sep + project['imageDir']);
    csvNftFile = File(projectDir.path + sep + project["rarityNftCsv"]);
    csvLayersFile = File(projectDir.path + sep + project["rarityLayersCsv"]);
    pngNftFile = File(projectDir.path + sep + project["rarityNftPng"]);
    pngLayersFile = File(projectDir.path + sep + project["rarityLayersPng"]);

    print("Config file found: ${configFile.path}");
  } else {
    print("Config file not found: ${configFile.path}");
    if (command != "config") {
      print("Aborting.");
      return;
    }
  }

  switch (command) {
    case "config":
      final name = project['configName'];
      final factor = project['factor'];
      final order = List<String>.from(project['configLayersOrder']);

      final configNew =
          Config.generate(name, layerDir, factor: factor, order: order);

      Io.writeJson(configFile, configNew);

      print("> ${configFile.path}");
      break;
    case "meta":
      Nft.generateMeta(configFile, metaDir);
      break;
    case "nft":
      Nft.generateNft(configFile, layerDir, imageDir, metaDir);
      break;
    case "cid":
      final cidSearch = args[1 + indexShift];
      final cidReplace = args[2 + indexShift];
      Config.updateCidMetadata(configFile, metaDir,
          cidReplace: cidSearch, cidSearch: cidReplace);
      break;
    case "rarity":
      await rarity(
          csvNftFile, csvLayersFile, pngNftFile, pngLayersFile, metaDir);
      break;
    default:
      throw "Unknow command: $command";
  }

  return;

  if (args[0] == "config") {
    final name = args[1];
    final layersDir = Directory(args[2]);
    final configFile = File(args[3]);
    final factor = args.length >= 5 ? double.parse(args[4]) : 3.0;
    final order = args.length >= 6 ? args[5].split(',') : <String>[];
    final config =
        Config.generate(name, layersDir, factor: factor, order: order);
    Io.writeJson(configFile, config);
  } else if (args[0] == "meta") {
    final configFile = File(args[1]);
    final metaDir = Directory(args[2]);

    Nft.generateMeta(configFile, metaDir);
  } else if (args[0] == "nft") {
    final configFile = File(args[1]);
    final genMetaDir = Directory(args[2]);
    final layersDir = Directory(args[3]);
    final imagesDir = Directory(args[4]);

    Nft.generateNft(configFile, layersDir, imagesDir, genMetaDir);
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

Future<void> rarity(File csvNftFile, File csvLayersFile, File pngNftFile,
    File pngLayersFile, Directory metaDir) async {
  List<MapEntry<String, double>> sortedNft = Rarity.nfts(metaDir);
  List<MapEntry<String, double>> sortedAttr = Rarity.layers(metaDir);

  await Rarity.drawChart(
      pngNftFile.path, sortedNft, 'NFTs: high = high rarity');
  await Rarity.drawChart(
      pngLayersFile.path, sortedAttr, 'Attributes: low = high rarity');

  Io.writeCsv(sortedNft, csvNftFile);
  Io.writeCsv(sortedAttr, csvLayersFile);

  print('Rarity NFTs: ${csvNftFile.path} (large = rare)');
  print('Rarity Layers: ${csvLayersFile.path} (small = rare)');
}

void usage() {
  // ---------------------------------------------------
  // EXAMPLES
  // ---------------------------------------------------

  print('USAGE\n');

  print('* Generate a config-json file:\n');
  print(
      "nftgen config <NAME> <LAYERS-DIR> <CONFIG-FILE> [ <WEIGHT-FACTOR>:3.0, <ORDERED-LIST>:[] ]");

  // ---------------------------------------------------

  print('\n* Generate NFT metadata based on a config-json file:\n');
  print("nftgen nft <CONFIG-FILE> <META-DIR>");

  // ---------------------------------------------------

  print('\n* Generate NFTs based on a config-json file and metadata:\n');
  print("nftgen nft <CONFIG-FILE> <META-DIR> <LAYERS-DIR> <IMAGE-DIR>");

  // ---------------------------------------------------

  print(
      '\n* Add CID code read from config or given as parameter to metadata files:\n');
  print("nftgen cid <CONFIG-FILE> <META-DIR> [<CID>, <CID-REPLACE>]");

  // ---------------------------------------------------

  print("\n* Generate rarity reports basd on metadata directory:\n");
  print("nftgen rarity <META-DIR> <RARITY-NFT.CSV> <RARITY-LAYERS.CSV>");

  // ---------------------------------------------------
  // EXAMPLES
  // ---------------------------------------------------

  print("\nEXAMPLES\n");
  print(
      "* Generate a config with equal weight distribution and ordered layers:\n");
  print(
      'nftgen config "NFT Name" .\\project\\layers\\ .\\project\\config_gen.json 0.0 "Background,Eyeball,Eye color,Iris,Shine,Bottom lid,Top lid"');

  // ---------------------------------------------------

  print("\n* Generate metadata based on a config:\n");
  print("nftgen meta .\\project\\config_gen.json .\\project\\meta\\");

  // ---------------------------------------------------

  print("\n* Generate NFTs based on a config:\n");
  print(
      "nftgen nft .\\project\\config_gen.json  .\\project\\meta\\ .\\project\\layers\\ .\\project\\images\\");

  // ---------------------------------------------------

  print("\n* Add CID code given as parameter to config and metadata:\n");
  print(
      "nftgen cid .\\project\\config_gen.json  .\\project\\meta\\ NEW-CID-CODE OLD-CID-CODE");

  print("\n* Replace CID with CID-REPLACE read from config to metadata:\n");
  print("nftgen cid .\\project\\config_gen.json  .\\project\\meta\\");

  // ---------------------------------------------------

  print("\n* Generate rarity reports basd on metadata directory:\n");
  print(
      "nftgen rarity .\\project\\meta\\ .\\project\\rarity_nft.csv .\\project\\rarity_layers.csv");
}
