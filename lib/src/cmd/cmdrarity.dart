import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/rarity.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/public/streamprint.dart';

class RarityCommand extends Command {
  @override
  final name = "rarity";
  @override
  final description = "Generates rarity CSV reports";

  RarityCommand() {
    argParser
      ..addOption('project',
          abbr: "p",
          help: 'The project path',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  void run() async {
    Directory projectDir = Directory(argResults!["project"]);
    final ProjectModel projectJson = ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(projectJson.metaDir);

    await rarity(
        projectJson.rarityNftCsv,
        projectJson.rarityLayersCsv,
        projectJson.rarityNftPng,
        projectJson.rarityLayersPng,
        projectJson.metaDir);
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
