import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/io.dart';
import 'package:nftgen/nft.dart';
import 'package:nftgen/streamprint.dart';

class NftCommand extends Command {
  @override
  final name = "nft";
  @override
  final description = "Generates NFT images based on metadata";

  NftCommand() {
    argParser.addOption('project',
        abbr: "p",
        help: 'The project path',
        valueHelp: 'path',
        defaultsTo: Directory.current.absolute.path);
  }

  @override
  void run() async {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');
    final Map<String, dynamic> projectJson = Io.mapJson(projectDir);

    final Directory metaDir = projectJson["metaDir"];
    final Directory layerDir = projectJson["layerDir"];
    final Directory imageDir = projectJson["imageDir"];

    Io.checkFolderExists(metaDir);
    Io.checkFolderExists(layerDir);

    await Nft.generateNft(projectFile, layerDir, imageDir, metaDir);
    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
