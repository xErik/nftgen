import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/config.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/streamprint.dart';

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
      ..addOption('name', mandatory: true, abbr: "n")
      ..addOption('layers', mandatory: true, abbr: "l")
      ..addOption('weight-stretch', abbr: "w", defaultsTo: "3.0")
      ..addFlag('overwrite', abbr: "o", defaultsTo: false, negatable: false);
  }

  @override
  void run() {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');

    final name = argResults!["name"];
    final layerDir = Directory(argResults!["layers"]);
    final factor = double.parse(argResults!["weight-stretch"]);
    final isOverwrite = argResults!["overwrite"] == true;

    if (projectFile.existsSync() && isOverwrite == false) {
      StreamPrint.prn(
          "Exiting, ${projectFile.path} exists, use -o to overwrite.");
      return;
    }

    final projectJsonNew =
        Config.generate(name, layerDir, factorWeights: factor);
    Io.writeJson(projectFile, projectJsonNew);
    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
