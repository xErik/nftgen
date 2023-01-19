import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/src/nft.dart';
import 'package:nftgen/core/helper/projectmodel.dart';

class MetaCommand extends Command {
  @override
  final name = "meta";
  @override
  final description = "Generates NFT metadata";

  MetaCommand() {
    argParser
      ..addOption('folder',
          abbr: "f",
          help: 'The project folder',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addOption('size',
          abbr: "s",
          help: 'The number of metadata to generate',
          valueHelp: 'int',
          defaultsTo: "-1")
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  void run() async {
    Directory projectDir = Directory(argResults!["folder"]);
    int size = int.parse(argResults!["size"]);
    // print('> ${projectDir.absolute.path}');
    File projectFile = Io.getProject(projectDir);
    Io.assertExistsFile(projectFile);

    final ProjectModel projectJson = ProjectModel.loadFromFolder(projectDir);

    await Nft.generateMeta(projectJson, size);
  }
}
