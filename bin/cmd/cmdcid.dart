import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/config.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/streamprint.dart';

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
          mandatory: true);
  }

  @override
  void run() {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');
    final Map<String, dynamic> projectJson = Io.mapJson(projectDir);

    final Directory metaDir = projectJson["metaDir"];
    final String cidSearch = projectJson["cidSearch"];
    final String cidReplace = argResults!["cid"];

    Io.checkFolderExists(metaDir);

    Config.updateCidMetadata(projectFile, metaDir,
        cidReplace: cidReplace, cidSearch: cidSearch);

    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
