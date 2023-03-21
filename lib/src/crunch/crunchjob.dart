import 'dart:io';

import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/src/shared/pngquant.dart';

/// Job for `IsolatePool`.
class CrunchJob extends PooledJob {
  final _quantExe = PngQuant.exePath;
  final int _crunchQuality;
  final Directory _dir;
  Process? _process;

  CrunchJob(this._crunchQuality, this._dir);

  @override
  Future<int> job() async {
    final str = "${_dir.path}${Platform.pathSeparator}*.png";

    _process = await Process.start(
        _quantExe.path,
        [
          '--speed',
          _crunchQuality.toString(),
          '--force',
          '--skip-if-larger',
          '--ext',
          '.png',
          str
        ],
        runInShell: true);

    stdout.addStream(_process!.stdout);
    stderr.addStream(_process!.stderr);

    return await _process!.exitCode;
  }

  @override
  Future<bool> stop() async {
    return _process == null ? false : _process!.kill();
  }
}
