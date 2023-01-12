import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/rarity.dart';
import 'package:nftgen/src/shared/streamprint.dart';

import 'projectjson.dart';

class RarityCommand extends Command with ProjectJson {
  @override
  final name = "rarity";
  @override
  final description = "Generates rarity CSV reports";

  RarityCommand() {
    argParser.addOption('project',
        abbr: "p",
        help: 'The project path',
        valueHelp: 'path',
        defaultsTo: Directory.current.absolute.path);
  }

  @override
  void run() async {
    Directory projectDir = Directory(argResults!["project"]);
    final Map<String, dynamic> projectJson = mapJson(projectDir);

    final File csvNftFile = projectJson["csvNftFile"];
    final File csvLayersFile = projectJson["csvLayersFile"];
    final File pngNftFile = projectJson["pngNftFile"];
    final File pngLayersFile = projectJson["pngLayersFile"];
    final Directory metaDir = projectJson["metaDir"];

    checkFolderExists(metaDir);

    await rarity(csvNftFile, csvLayersFile, pngNftFile, pngLayersFile, metaDir);
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

    StreamPrint.prn('Rarity NFTs: ${csvNftFile.path} (large = rare)');
    StreamPrint.prn('Rarity Layers: ${csvLayersFile.path} (small = rare)');
  }
}
