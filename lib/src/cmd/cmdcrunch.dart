import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/io.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/src/shared/eta.dart';
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
          defaultsTo: "4")
      ..addFlag("overwrite",
          abbr: "o", defaultsTo: false, help: 'Re-crunch all layer files?')
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  Future run() async {
    final sep = Platform.pathSeparator;
    final eta = Eta();
    final Directory projectDir = Directory(argResults!["folder"]);
    final int crunchQuality = int.parse(argResults!["quality"]);
    final bool isOverwrite = argResults!["overwrite"];
    final ProjectModel projectModel =
        await ProjectModel.loadFromFolder(projectDir);
    final List<Directory> work = [];
    final quantExe = File('.\\bin\\pngquant\\pngquant.exe');

    if (quantExe.existsSync() == false) {
      throw NftFileNotFoundException(
          'pnqquant.exe not found: ${quantExe.path}');
    }

    if (crunchQuality < 1 || crunchQuality > 11) {
      throw 'Crunch quality -q must be between 1 and 11.';
    }

    final crunchDir = projectModel.layerCrunchDir;

    if (crunchDir.existsSync()) {
      if (isOverwrite == true) {
        StreamPrint.prn('Deleting: ${crunchDir.path}');
        crunchDir.deleteSync(recursive: true);
      } else {
        StreamPrint.warn(
            'Crunched PNGs exist and overwrite is not specified: -o');
        throw NftCliException('NO');
      }
    }

    StreamPrint.prn("Crunching PNGs with quality $crunchQuality (1-11)");

    Io.assertExistsFolder(projectModel.layerDir);

    projectModel.layerDir.listSync().whereType<Directory>().forEach((dir) {
      if (dir.path.contains(' ')) {
        throw NftCliException(
            'Spaces in folder names NOT allowed: ${dir.path}');
      }
    });

    StreamPrint.progress('Copying to: ${crunchDir.path}');
    await copyPath(projectModel.layerDir.path, crunchDir.path);

    crunchDir.listSync().whereType<Directory>().forEach((dir) {
      work.add(Directory(dir.path));
    });

    final fileCount = crunchDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((element) => element.path.endsWith('.png'))
        .length;

    final Map<String, List<int>> fileShrink = {};

    StreamPrint.progress('Crunching ...');

    for (Directory dir in work) {
      dir
          .listSync()
          .whereType<File>()
          .where((element) => element.path.endsWith('.png'))
          .forEach((png) {
        final pngSize = png.statSync().size;
        fileShrink[png.path] = [pngSize];
      });

      final str = "${dir.path}$sep*.png";

      Process.runSync(
          quantExe.path,
          [
            '--speed',
            crunchQuality.toString(),
            '--force',
            '--skip-if-larger',
            '--ext',
            '.png',
            // '--verbose',
            // '"${dir.path}$sep*.png"'
            str
          ],
          runInShell: true);

      dir
          .listSync()
          .whereType<File>()
          .where((element) => element.path.endsWith('.png'))
          .forEach((png) {
        final pngSize = png.statSync().size;
        fileShrink[png.path]!.add(pngSize);
      });

      eta.write(fileShrink.length, fileCount,
          "Crunch average: ${_avgShrunk(fileShrink)} %");
    }

    StreamPrint.prn('Crunching done.');
  }

  _avgShrunk(Map<String, List<int>> fileShrink) {
    List<int> shrinking = [];

    for (List<int> vals in fileShrink.values) {
      final shrinkPerc =
          ((100 / vals.elementAt(0)) * vals.elementAt(1)).toInt();
      shrinking.add(shrinkPerc);
    }

    return shrinking.reduce((sum, val) => sum + val) ~/ fileShrink.length;
  }
}
