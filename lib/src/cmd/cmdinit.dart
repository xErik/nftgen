import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/config.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/public/nftcliexception.dart';
import 'package:nftgen/public/streamprint.dart';

class InitCommand extends Command {
  @override
  final name = "init";
  @override
  final description = "Initiates a new project";

  InitCommand() {
    argParser
      ..addOption(
        'project',
        mandatory: true,
        abbr: "p",
        help: 'The project path',
        valueHelp: 'path',
      )
      ..addOption('name',
          mandatory: true, abbr: "n", help: 'NFT name', valueHelp: 'string')
      ..addOption('layers',
          mandatory: true,
          abbr: "l",
          help: 'The layers path',
          valueHelp: 'path')
      ..addOption('weight-stretch',
          abbr: "w",
          defaultsTo: "3.0",
          help: 'How to distribute weights within layer',
          valueHelp: 'double')
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
    final Directory projectDir = Directory(argResults!["project"]);
    final File projectFile = Io.getProject(projectDir);

    final name = argResults!["name"];
    final layerDir = Directory(argResults!["layers"]);
    final factor = double.parse(argResults!["weight-stretch"]);
    final isOverwrite = argResults!["overwrite"];

    if (isOverwrite == false) {
      try {
        Io.asserExistsNotFile(projectFile);
      } on NftCliException catch (e) {
        throw NftCliException("${e.message}, use -o to overwrite.");
      } catch (e) {
        throw NftCliException(e.toString());
      }
    }

    Config.generate(name, layerDir, factorWeights: factor)
        .saveToFolder(projectDir);

    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
