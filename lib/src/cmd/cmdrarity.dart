import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/rarity.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';

class RarityCommand extends Command {
  @override
  final name = "rarity";
  @override
  final description = "Generates rarity CSV reports";

  RarityCommand() {
    argParser
      ..addOption('folder',
          abbr: "f",
          help: 'The project folder',
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
  Future run() async {
    Directory projectDir = Directory(argResults!["folder"]);
    final bool doCharts = argResults!["charts"];
    final ProjectModel projectJson =
        await ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(projectJson.metaDir);

    List<MapEntry<String, double>> sortedNft =
        await Rarity.nfts(projectJson.metaDir);
    List<MapEntry<String, double>> sortedAttr =
        await Rarity.layers(projectJson.metaDir);

    await Io.writeCsv(sortedNft, projectJson.rarityNftCsv);
    await Io.writeCsv(sortedAttr, projectJson.rarityLayersCsv);

    StreamPrint.prn(
        'Rarity NFTs: ${projectJson.rarityNftCsv.path} (large = rare)');
    StreamPrint.prn(
        'Rarity Layers: ${projectJson.rarityLayersCsv.path} (small = rare)');

    // ------------------------------------------------------------
    // CHARTS
    // ------------------------------------------------------------

    if (doCharts) {
      await Rarity.drawChart(
          projectJson.rarityNftPng.path, sortedNft, 'NFTs: high = high rarity');
      await Rarity.drawChart(projectJson.rarityLayersPng.path, sortedAttr,
          'Attributes: low = high rarity');

      StreamPrint.prn(
          'Chart Rarity NFTs: ${projectJson.rarityNftPng.path} (large = rare)');
      StreamPrint.prn(
          'Chart Rarity Layers: ${projectJson.rarityLayersPng.path} (small = rare)');
    }
  }
}
