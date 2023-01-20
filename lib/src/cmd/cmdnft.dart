import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/nft.dart';

class NftCommand extends Command {
  @override
  final name = "nft";
  @override
  final description = "Generates NFT images based on metadata";
  final DrawBase? drawService;

  NftCommand(this.drawService) {
    argParser
      ..addOption('folder',
          abbr: "f",
          help: 'The project folder',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addOption('size',
          abbr: "s",
          help: 'The number of NFTs to generate',
          valueHelp: 'int',
          defaultsTo: "-1")
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  Future<void> run() async {
    Directory projectDir = Directory(argResults!["folder"]);
    int size = int.parse(argResults!["size"]);
    File projectFile = Io.getProject(projectDir);

    Io.assertExistsFile(projectFile);

    final ProjectModel model = ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(model.metaDir);
    Io.assertExistsFolder(model.layerDir);

    await Nft.generateNft(projectDir, size, model.layerDir, model.imageDir,
        model.metaDir, drawService);
  }
}
