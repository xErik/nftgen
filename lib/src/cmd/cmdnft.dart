import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/nft.dart';
import 'package:nftgen/public/streamprint.dart';

class NftCommand extends Command {
  @override
  final name = "nft";
  @override
  final description = "Generates NFT images based on metadata";

  NftCommand() {
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
  Future<void> run() async {
    Directory projectDir = Directory(argResults!["project"]);
    File projectFile = Io.getProject(projectDir);

    Io.assertExistsFile(projectFile);

    final ProjectModel model = ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(model.metaDir);
    Io.assertExistsFolder(model.layerDir);

    await Nft.generateNft(
        projectDir, model.layerDir, model.imageDir, model.metaDir);

    StreamPrint.prn("Created: ${projectFile.path}");
  }
}
