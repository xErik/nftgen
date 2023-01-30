import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/main.dart';
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
      // ..addFlag("crunch-layers-forced",
      //     abbr: "c",
      //     defaultsTo: false,
      //     help: 'Force a re-crunch of all layer files?')
      ..addFlag("jpg",
          aliases: ["jpeg"],
          abbr: "j",
          defaultsTo: true,
          help: 'Write NFTs as JPGs?')
      ..addOption('jpg-quality',
          abbr: "q",
          help: 'The JPG quality between 1 and 100',
          valueHelp: 'int',
          defaultsTo: "80")
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  run() async {
    Directory projectDir = Directory(argResults!["folder"]);
    int size = int.parse(argResults!["size"]);
    // bool isForceRecrunch = argResults!["crunch-layers-forced"];
    bool isWriteJpg = argResults!["jpg"];
    int jpgQuality = int.parse(argResults!["jpg-quality"]);
    File projectFile = Io.getProject(projectDir);

    Io.assertExistsFile(projectFile);

    final ProjectModel model = await ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(model.metaDir);
    Io.assertExistsFolder(model.layerCrunchDir);

    await Nft.generateNft(projectDir, size, model.layerCrunchDir,
        model.imageDir, model.metaDir, drawService, isWriteJpg, jpgQuality);
  }
}
