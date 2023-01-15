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
      ..addFlag("charts",
          abbr: "c",
          defaultsTo: false,
          help: 'draw and save small image charts?')
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  void run() async {
    Directory projectDir = Directory(argResults!["project"]);
    final bool doCharts = argResults!["charts"];
    final ProjectModel projectJson = ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(projectJson.metaDir);

    List<MapEntry<String, double>> sortedNft = Rarity.nfts(projectJson.metaDir);
    List<MapEntry<String, double>> sortedAttr =
        Rarity.layers(projectJson.metaDir);

    if (doCharts) {
      await Rarity.drawChart(
          projectJson.rarityNftPng.path, sortedNft, 'NFTs: high = high rarity');
      await Rarity.drawChart(projectJson.rarityLayersPng.path, sortedAttr,
          'Attributes: low = high rarity');
    }

    Io.writeCsv(sortedNft, projectJson.rarityNftCsv);
    Io.writeCsv(sortedAttr, projectJson.rarityLayersCsv);

    StreamPrint.prn(
        'Rarity NFTs: ${projectJson.rarityNftCsv.path} (large = rare)');
    StreamPrint.prn(
        'Rarity Layers: ${projectJson.rarityLayersCsv.path} (small = rare)');
  }
}