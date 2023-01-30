import 'dart:io';

import 'package:io/io.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:nftgen/src/shared/pngquant.dart';
import 'package:path/path.dart';

class Crunch {
  static Future<void> crunchLayers(
      ProjectModel projectModel, int crunchQuality) async {
    final sep = Platform.pathSeparator;
    final eta = Eta();
    final List<Directory> work = [];
    final quantExe = PngQuant.exePath;

    if (crunchQuality < 1 || crunchQuality > 11) {
      throw NftCliException('Crunch quality -q must be between 1 and 11.');
    }

    final crunchDir = projectModel.layerCrunchDir;

    projectModel.layerDir.listSync().whereType<Directory>().forEach((dir) {
      if (dir.path.contains(' ')) {
        throw NftCliException(
            'Spaces in folder names NOT allowed: ${dir.path}');
      }
    });

    StreamPrint.progress('Copying layers to: ${crunchDir.path}');
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
  }

  static int _avgShrunk(Map<String, List<int>> fileShrink) {
    List<int> shrinking = [];

    for (List<int> vals in fileShrink.values) {
      final shrinkPerc =
          ((100 / vals.elementAt(0)) * vals.elementAt(1)).toInt();
      shrinking.add(shrinkPerc);
    }

    return shrinking.reduce((sum, val) => sum + val) ~/ fileShrink.length;
  }
}
