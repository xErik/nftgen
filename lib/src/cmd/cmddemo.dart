import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/cli.dart';
import 'package:nftgen/core/helper/nftcliexception.dart';
import 'package:nftgen/core/helper/streamprint.dart';
import 'package:nftgen/src/shared/io.dart';

class DemoCommand extends Command {
  @override
  final name = "demo";
  @override
  late final String description;
  final String currentSize = 50.toString();

  DemoCommand() {
    description = "Generates $currentSize NFT images based on layers";

    argParser
      ..addOption('folder',
          abbr: "f",
          help: 'The project folder',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addOption('layers',
          mandatory: true,
          abbr: "l",
          help: 'The layers path',
          valueHelp: 'path')
      ..addOption('name',
          abbr: "n", help: 'NFT name', valueHelp: 'string', defaultsTo: "NFT")
      ..addOption('size',
          abbr: "s",
          help: 'The number of NFTs to generate',
          valueHelp: 'int',
          defaultsTo: currentSize)
      ..addOption('weight-stretch',
          abbr: "w",
          defaultsTo: "2.0",
          help: 'How to distribute weights within layer',
          valueHelp: 'double')
      ..addOption('probability-stretch',
          abbr: "p",
          defaultsTo: "0.0",
          help: 'How to distribute probabilities withing layers',
          valueHelp: 'double between 0.0 and 1.0')
      ..addFlag('overwrite',
          abbr: "o", defaultsTo: true, help: 'Overwrite existing project.json?')
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  Future<void> run() async {
    final Directory projectDir = Directory(argResults!["folder"]);
    final Directory layerDir = Directory(argResults!["layers"]);
    final int size = int.parse(argResults!["size"]);
    final String name = argResults!["name"];
    final w = double.parse(argResults!["weight-stretch"]);
    final p = double.parse(argResults!["probability-stretch"]);
    final isOverwrite = argResults!["overwrite"];
    // print('  BBB $size');
    try {
      Io.assertExistsFolder(layerDir);

      await init(projectDir.path, layerDir.path, name, isOverwrite, w: w, p: p);

      await meta(projectDir.path, size);
      await rarity(projectDir.path);
      await nft(projectDir.path, size: size);

      StreamPrint.prn("Demo finished with size: $size");
    } on NftCliException catch (e) {
      StreamPrint.err(e.message);
    } catch (e) {
      StreamPrint.err(e.toString());
    }
  }
}
