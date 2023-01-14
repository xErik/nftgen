import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/nft.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/public/streamprint.dart';

class MetaCommand extends Command {
  @override
  final name = "meta";
  @override
  final description = "Generates NFT metadata";

  MetaCommand() {
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
  void run() {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile = Io.getProject(projectDir);

    Io.assertExistsFile(projectFile);

    final ProjectModel projectJson = ProjectModel.loadFromFolder(projectDir);

    Nft.generateMeta(projectFile, projectJson.metaDir);
    StreamPrint.prn("Created: ${projectJson.metaDir.path}");
  }
}
