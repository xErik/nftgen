import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:filesize/filesize.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/src/project.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:path/path.dart';

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
      ..addFlag("kill",
          abbr: "k",
          defaultsTo: true,
          help: 'exit(64) process in case of error?');
  }

  @override
  Future run() async {
    final sep = Platform.pathSeparator;
    final eta = Eta()..start();
    final Directory projectDir = Directory(argResults!["folder"]);
    final int crunchQuality = int.parse(argResults!["quality"]);
    final ProjectModel projectJson =
        await ProjectModel.loadFromFolder(projectDir);
    final List<Map<String, File>> work = [];
    final quantExe = File('.\\bin\\pngquant\\pngquant.exe');

    if (quantExe.existsSync() == false) {
      throw NftFileNotFoundException(
          'pnqquant.exe not found: ${quantExe.path}');
    }

    if (crunchQuality < 1 || crunchQuality > 11) {
      throw 'Crunch quality -q must be between 1 and 11.';
    }

    StreamPrint.prn("Crunching PNGs with quality $crunchQuality (1-11)");

    Io.assertExistsFolder(projectJson.layerDir);

    final crunchDir = Directory('${projectDir.path}${sep}layer_crunched');
    if (crunchDir.existsSync()) {
      crunchDir.deleteSync(recursive: true);
    }

    projectJson.layerDir.listSync().whereType<Directory>().forEach((dir) {
      dir
          .listSync()
          .where((file) => file.path.endsWith('.png'))
          .forEach((png) async {
        final dir =
            Directory('${crunchDir.path}$sep${basename(png.parent.path)}');

        final out = File('${dir.path}$sep${basename(png.path)}');

        work.add({
          'png': File(png.path),
          'out': out,
        });
      });
    });

    final List<int> shrinking = [];

    for (var i = 0; i < work.length; i++) {
      final png = work[i]["png"]!;
      final out = work[i]["out"]!;

      // final filePng = File(png);
      // final fileOut = File(out);

      out.parent.createSync(recursive: true);

      await Process.run(
              quantExe.path,
              [
                '--speed',
                crunchQuality.toString(),
                '--force',
                '--skip-if-larger',
                '--output',
                out.path,
                png.path
              ],
              runInShell: true)
          .then((ProcessResult pr) {
        // print(pr.exitCode);
        // print(pr.stdout);
        // stderr.writeln(pr.stderr);
      });

      final pngSize = png.statSync().size;
      final outSize = out.statSync().size;
      final shrinkPerc = ((100 / pngSize) * outSize).toInt();

      shrinking.add(shrinkPerc);

      eta.write(i + 1, work.length,
          "${basename(png.path)} ${filesize(outSize)} $shrinkPerc %");
    }

    final shrunk =
        shrinking.reduce((sum, val) => sum + val) ~/ shrinking.length;

    StreamPrint.prn("Crunched PNGs with average of $shrunk %");
  }
}
