import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/config.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/nft.dart';
import 'package:nftgen/src/shared/streamprint.dart';

import 'projectjson.dart';

class CidCommand extends Command with ProjectJson {
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
    final Map<String, dynamic> projectJson = mapJson(projectDir);

    final Directory metaDir = projectJson["metaDir"];
    final String cidSearch = projectJson["cidSearch"];
    final String cidReplace = argResults!["cid"];

    checkFolderExists(metaDir);

    Config.updateCidMetadata(projectFile, metaDir,
        cidReplace: cidReplace, cidSearch: cidSearch);

    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
