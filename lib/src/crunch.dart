import 'dart:io';
import 'dart:math';

import 'package:io/io.dart';
import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:nftgen/src/crunch/crunchjob.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:nftgen/src/shared/stopper.dart';

class Crunch {
  static Future<void> crunchLayers(
      ProjectModel projectModel, int crunchQuality) async {
    final etaMain = Eta();
    final List<Directory> work = [];
    final pool = IsolatePool(max(Platform.numberOfProcessors - 2, 2));
    await pool.start();

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

    StreamPrint.progress('Crunching ...');

    final fileCountAll = crunchDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((element) => element.path.endsWith('.png'))
        .length;

    final Map<String, List<int>> fileShrink = {};

    final List<Future> futures = [];

    for (Directory dir in work) {
      _fileShrink(dir, fileShrink);
    }

    bool isStopped = false;

    for (Directory dir in work) {
      try {
        Stopper.assertNotStopped();
      } catch (_) {
        isStopped = true;
      }

      if (isStopped == true) {
        StreamPrint.warn('Stopping ...');
        break;
      }

      final eta = Eta(etaMain.start);

      final fileCountDir = dir
          .listSync(recursive: true)
          .whereType<File>()
          .where((element) => element.path.endsWith('.png'))
          .length;

      final future = pool.scheduleJob(CrunchJob(crunchQuality, dir));

      future.then((value) {
        _fileShrink(dir, fileShrink);

        eta.write(fileCountDir, fileCountAll, "Crunch average: ??? %");

        // eta.write(fileCountDir, fileCountAll,
        //     "Crunch average: ${_avgShrunk(fileShrink)} %");
      }).onError((error, stackTrace) {
        print(error);
        throw error!;
      });

      futures.add(future);
    }
    // print(futures);
    await Future.wait(futures, eagerError: true);
  }

  static _fileShrink(Directory dir, Map<String, List<int>> fileShrink) {
    dir
        .listSync()
        .whereType<File>()
        .where((element) => element.path.endsWith('.png'))
        .forEach((png) {
      final pngSize = png.statSync().size;
      if (fileShrink.containsKey(png.path) == false) {
        fileShrink[png.path] = [pngSize];
      } else {
        fileShrink[png.path]!.add(pngSize);
      }
    });
  }

  // static int _avgShrunk(Map<String, List<int>> fileShrink) {
  //   List<int> shrinking = [];

  //   for (List<int> vals in fileShrink.values) {
  //     print(vals);

  //     final shrinkPerc =
  //         ((100 / vals.elementAt(0)) * vals.elementAt(1)).toInt();
  //     shrinking.add(shrinkPerc);
  //   }

  //   return shrinking.reduce((sum, val) => sum + val) ~/ fileShrink.length;
  // }
}
