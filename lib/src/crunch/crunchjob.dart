import 'dart:io';

import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/src/shared/pngquant.dart';

/// Job for `IsolatePool`.
class CrunchJob extends PooledJob {
  final quantExe = PngQuant.exePath;
  final int crunchQuality;
  final Directory dir;

  CrunchJob(this.crunchQuality, this.dir);

  @override
  Future<void> job() async {
    final str = "${dir.path}${Platform.pathSeparator}*.png";

    await Process.run(
        quantExe.path,
        [
          '--speed',
          crunchQuality.toString(),
          '--force',
          '--skip-if-larger',
          '--ext',
          '.png',
          // '--verbose',
          str
        ],
        runInShell: true);
  }
}
