import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/public/nftcliexception.dart';
import 'package:nftgen/src/config.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/public/streamprint.dart';
import 'package:path/path.dart';

class CidCommand extends Command {
  @override
  final name = "cid";
  @override
  final description = "Updates CID of generated metadata";

  CidCommand() {
    argParser
      ..addOption('project',
          abbr: "p",
          help: 'The project path',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addOption('cid',
          abbr: "c",
          help: 'Your CID',
          valueHelp: 'alphanumeric',
          mandatory: true)
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  void run() {
    final Directory projectDir = Directory(argResults!["project"]);
    final File projectFile = Io.getProject(projectDir);
    final ProjectModel projectJson = ProjectModel.loadFromFolder(projectDir);
    final String cidReplace = argResults!["cid"];

    Io.assertExistsFolder(projectJson.metaDir);

    Config.updateCidMetadata(projectDir,
        cidReplace: cidReplace, cidSearch: projectJson.cidCode);

    StreamPrint.prn("Updated CID: ${projectFile.path}");
    StreamPrint.prn(
        "Updated CID: ${normalize(projectJson.metaDir.path)}${Platform.pathSeparator}*.json");
  }
}
