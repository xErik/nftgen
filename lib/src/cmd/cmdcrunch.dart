import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/src/crunch.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';

class CrunchCommand extends Command {
  @override
  final name = "crunch";
  @override
  final description = "Crunches layer PNGs";

  CrunchCommand() {
    argParser
      ..addOption('folder',
          abbr: "f",
          help: 'The project folder',
          valueHelp: 'path',
          defaultsTo: Directory.current.absolute.path)
      ..addOption('quality',
          abbr: "q",
          help: 'The crunch quality',
          valueHelp: 'int between 1 (slow) and 11 (fast)',
          defaultsTo: "11")
      ..addFlag("overwrite",
          abbr: "o", defaultsTo: false, help: 'Re-crunch all layer files?')
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  Future run() async {
    final Directory projectDir = Directory(argResults!["folder"]);
    final int crunchQuality = int.parse(argResults!["quality"]);
    final bool isOverwrite = argResults!["overwrite"];
    final ProjectModel projectModel =
        await ProjectModel.loadFromFolder(projectDir);

    Io.assertExistsFolder(projectModel.layerDir);

    if (crunchQuality < 1 || crunchQuality > 11) {
      throw 'Crunch quality -q must be between 1 and 11.';
    }

    final crunchDir = projectModel.layerCrunchDir;

    if (crunchDir.existsSync()) {
      if (isOverwrite == true) {
        StreamPrint.prn('Deleting: ${crunchDir.path}');
        crunchDir.deleteSync(recursive: true);
      } else {
        // StreamPrint.warn(
        //     'Crunched PNGs exist and overwrite is not specified: -o');
        throw NftCliException(
            'Crunched PNGs exist and overwrite is not specified: -o');
      }
    }

    StreamPrint.prn("Crunching PNGs with quality $crunchQuality (1-11)");

    await Crunch.crunchLayers(projectModel, crunchQuality);

    StreamPrint.prn('Crunching done.');
  }
}
