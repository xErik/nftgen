import 'dart:io';

import 'package:nftgen/config.dart';
import 'package:nftgen/nft.dart';
import 'package:nftgen/rarity.dart';
import 'package:nftgen/io.dart';

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
  late final Map<String, dynamic> project;

  late final String name;
  late final double factor;
  late final List<String> order;

  late final Directory metaDir;
  late final Directory layerDir;
  late final Directory imageDir;

  late final File csvNftFile;
  late final File csvLayersFile;
  late final File pngNftFile;
  late final File pngLayersFile;

  String command = args[0];
  Directory? projectDir;

  // ------------------------------------------------------------
  // PROJECT FILE
  // ------------------------------------------------------------

  File projectFile = File('project/project.json');

  if (args.length >= 2 && Directory(args[1]).existsSync()) {
    projectDir = Directory(args[1]);
    if (projectDir.existsSync()) {
      indexShift = 1;
      projectFile = File("${projectDir.path}${sep}project.json");
      project = Io.readJson(projectFile);
      print('Project directory defined, using: ${projectDir.path}');
    }
  }

  if (projectDir == null) {
    projectDir = Directory("project");
    projectFile = File("${projectDir.path}${sep}project.json");
    project = Io.readJson(projectFile);
    print('Project directory not defined, using: ${projectDir.path}');
  }

  name = project['configName'];
  factor = project['configWeightsFactor'];
  order = List<String>.from(project['configLayersOrder']);
  metaDir = Directory(projectDir.path + sep + project['metaDir']);
  layerDir = Directory(projectDir.path + sep + project['layerDir']);
  imageDir = Directory(projectDir.path + sep + project['imageDir']);
  csvNftFile = File(projectDir.path + sep + project["rarityNftCsv"]);
  csvLayersFile = File(projectDir.path + sep + project["rarityLayersCsv"]);
  pngNftFile = File(projectDir.path + sep + project["rarityNftPng"]);
  pngLayersFile = File(projectDir.path + sep + project["rarityLayersPng"]);

  // ------------------------------------------------------------
  // CONFIG FILE
  // ------------------------------------------------------------

  final configFile = File(projectDir.path + sep + project['configFile']);
  Map<String, dynamic> config = {};

  if (File(configFile.path).existsSync() == false && command != "config") {
    print(
        "Exiting, config file not found: ${configFile.path} COMMAND: $command");
    return;
  } else if (File(configFile.path).existsSync()) {
    config = Io.readJson(configFile);
  }

  // ------------------------------------------------------------
  // EXECUTE COMMAND
  // ------------------------------------------------------------

  switch (command) {
    case "project":
      print(args);
      final name = args[1 + indexShift];
      final order = List<String>.from(args[2 + indexShift].split(','));
      if (order.isEmpty) {
        print("Exiting, order of layers is empty.");
        return;
      }
      final projectNew = Config.generateProject(name, order);
      Io.writeJson(projectFile, projectNew);
      print("Created: ${projectFile.path}");
      break;
    case "config":
      final configNew =
          Config.generate(name, layerDir, factor: factor, order: order);
      Io.writeJson(configFile, configNew);
      print("Created: ${configFile.path}");
      break;
    case "meta":
      Nft.generateMeta(configFile, metaDir);
      break;
    case "nft":
      Nft.generateNft(configFile, layerDir, imageDir, metaDir);
      break;
    case "cid":
      final cidSearch = config["cidCode"];
      final cidReplace = args[1 + indexShift];
      Config.updateCidMetadata(configFile, metaDir,
          cidReplace: cidReplace, cidSearch: cidSearch);
      break;
    case "rarity":
      await rarity(
          csvNftFile, csvLayersFile, pngNftFile, pngLayersFile, metaDir);
      break;
    default:
      throw "Unknow command: $command";
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

  print('* Generate a project file:\n');
  print("  nftgen project [<PROJECT-DIR>] <PROJECT-NAME> <LAYER-ORDER>");

  print('* Generate a config-json file basd on ./project/project.json:\n');
  print("  nftgen config [<PROJECT-DIR>]");

  // ---------------------------------------------------

  print('\n* Generate metadata based on ./project/project.json:\n');
  print("  nftgen nft meta [<PROJECT-DIR>]");

  // ---------------------------------------------------

  print(
      '\n* Generate NFTs based on ./project/project.json\n  and ./project/meta/<metadata.json>:\n');
  print("  nftgen nft [<PROJECT-DIR>]");

  // ---------------------------------------------------

  print(
      '\n* Add CID code to metadata from ./project/project.json\n  or command line parameter:\n');
  print("  nftgen cid [<PROJECT-DIR>, <CID>]");

  // ---------------------------------------------------

  print(
      "\n* Generate rarity reports basd on ./project/project.json\n  and ./project/meta/<metadata.json>:\n");
  print("  nftgen rarity <PROJECT-DIR>");
}
