import 'dart:io';

import 'package:nftgen/framework/nftcliexception.dart';

class PngQuant {
  static final _sep = Platform.pathSeparator;
  static File? pngquant;

  static File get exePath {
    // EXE: C:\Users\Erik\com_nft_generate\main.dart
    // DART: C:\Users\Erik\com_nft_generate\bin\nftgen.dart

    if (pngquant != null) {
      return pngquant!;
    }

    final f = File(Platform.script.toFilePath());
    final testExe =
        File('${f.parent.path}${_sep}bin${_sep}pngquant${_sep}pngquant.exe');
    final testDart = File('${f.parent.path}${_sep}pngquant${_sep}pngquant.exe');

    if (testExe.existsSync()) {
      pngquant = testExe;
    } else if (testDart.existsSync()) {
      pngquant = testDart;
    } else {
      throw NftCliException('File not found: pngquant.exe');
    }

    return pngquant!;
  }
}
