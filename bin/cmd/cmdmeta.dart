import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/nft.dart';
import 'package:nftgen/streamprint.dart';

class MetaCommand extends Command {
  @override
  final name = "meta";
  @override
  final description = "Generates NFT metadata";

  MetaCommand() {
    argParser.addOption('project',
        abbr: "p",
        help: 'The project path',
        valueHelp: 'path',
        defaultsTo: Directory.current.absolute.path);
  }

  @override
  void run() {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');

    final Map<String, dynamic> projectJson = Io.mapJson(projectDir);

    final Directory metaDir = projectJson["metaDir"];

    Nft.generateMeta(projectFile, metaDir);
    StreamPrint.prn("Created: ${metaDir.path}");
  }
}
