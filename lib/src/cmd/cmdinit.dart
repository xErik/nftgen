import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/project.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/streamprint.dart';

class InitCommand extends Command {
  @override
  final name = "init";
  @override
  final description = "Initiates a new project";

  InitCommand() {
    argParser
      ..addOption(
        'folder',
        mandatory: true,
        abbr: "f",
        help: 'The project folder',
        valueHelp: 'path',
      )
      ..addOption('name',
          abbr: "n", help: 'NFT name', valueHelp: 'string', defaultsTo: "NFT")
      ..addOption('layers',
          mandatory: true,
          abbr: "l",
          help: 'The layers path',
          valueHelp: 'path')
      ..addOption('weight-stretch',
          abbr: "w",
          defaultsTo: "2.0",
          help: 'How to distribute weights within layer',
          valueHelp: 'double')
      ..addOption('probability-stretch',
          abbr: "p",
          defaultsTo: "0.5",
          help: 'How to distribute probabilities withing layers',
          valueHelp: 'double between 0.0 and 1.0')
      ..addFlag('overwrite',
          abbr: "o",
          defaultsTo: false,
          help: 'Overwrite existing project.json?')
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  void run() {
    final Directory projectDir = Directory(argResults!["folder"]);
    final File projectFile = Io.getProject(projectDir);

    final name = argResults!["name"];
    final layerDir = Directory(argResults!["layers"]);
    final factorWeights = double.parse(argResults!["weight-stretch"]);
    final factorLayers = double.parse(argResults!["probability-stretch"]);
    final isOverwrite = argResults!["overwrite"];

    if (isOverwrite == false) {
      try {
        Io.asserExistsNotFile(projectFile);
      } on NftFileNotFoundException catch (e) {
        throw NftFileNotFoundException("${e.message}, use -o to overwrite.");
      }
    }

    Project.generate(name, projectDir, layerDir,
        factorWeights: factorWeights, factorLayers: factorLayers);

    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
