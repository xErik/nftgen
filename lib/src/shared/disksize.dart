import 'dart:io';
import 'dart:math';

import 'package:filesize/filesize.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:universal_disk_space/universal_disk_space.dart';

class DiskSize {
  /// Check free space at file count X for quick exiting of running
  /// process and saving time.
  final _checkAtXFile = 5;

  /// Check free space every X files.
  final _checkEveryXFiles = 50;

  /// The size of free space subtracted from the total free space.
  /// Necessary free space to keep the system operational.
  final _freeSpaceBarrierBytes = 2000 * 1024 * 1024;

  DiskSpace? _diskSpaceRef;
  final List<int> _spaceUsedCurrentBytes = [];
  int _freeSpaceCurrentBytes = 0;
  int _spaceUsedExpectedBytes = 0;

  static final DiskSize _singleton = DiskSize._internal();

  factory DiskSize() {
    return _singleton;
  }

  DiskSize._internal();

  Future<bool> _hasFreeSpace(int maxFileCount) async {
    _diskSpaceRef ??= DiskSpace();
    await _diskSpaceRef!.scan();
    final disk = _diskSpaceRef!.getDisk(Directory('C:'));

    final spaceUsedCurrent =
        _spaceUsedCurrentBytes.reduce((sum, val) => sum + val);
    final filesCurrent = _spaceUsedCurrentBytes.length;

    _spaceUsedExpectedBytes =
        ((spaceUsedCurrent / filesCurrent) * maxFileCount).toInt();

    _freeSpaceCurrentBytes = disk.availableSpace;

    final freeSpaceExpected =
        max(0, _freeSpaceCurrentBytes - _spaceUsedExpectedBytes);

    return freeSpaceExpected <= _freeSpaceBarrierBytes;
  }

  /// Use `DiskSpace().reset()` before for each run writing files.
  void resetAll() {
    _diskSpaceRef = null;
    _spaceUsedCurrentBytes.clear();
    _freeSpaceCurrentBytes = 0;
    _spaceUsedExpectedBytes = 0;
  }

  Future addFile(int fileSize, int maxFileCount) async {
    _spaceUsedCurrentBytes.add(fileSize);

    if (_spaceUsedCurrentBytes.length < _checkAtXFile) {
      return;
    }

    if (_spaceUsedCurrentBytes.length % _checkEveryXFiles == 0 ||
        _spaceUsedCurrentBytes.length == _checkAtXFile) {
      bool isFatal = await _hasFreeSpace(maxFileCount);

      if (isFatal == true) {
        StreamPrint.err(_message(maxFileCount, "FATAL"));
        final needed = filesize(_spaceUsedExpectedBytes);

        throw NftNotEnoughFreespaceException(
            'Not enough disk space for $maxFileCount NFTs. $needed are needed.');
      } else {
        StreamPrint.prn(_message(maxFileCount));
      }
    }
  }

  String _message(int maxFileCount, [String type = 'OK']) {
    final prefix = _spaceUsedCurrentBytes.length.toString().padLeft(4, ' ');
    final needed = filesize(_spaceUsedExpectedBytes);
    final barrier = filesize(_freeSpaceBarrierBytes);
    final freeCurrent = filesize(_freeSpaceCurrentBytes);

    return '$prefix / $maxFileCount $type-DISK-SPACE FREE: $freeCurrent, KEEP: $barrier, NEEDED: $needed';
  }
}
