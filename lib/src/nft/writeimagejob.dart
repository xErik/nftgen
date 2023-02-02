import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/src/shared/pngquant.dart';

class WriteImage extends PooledJob {
  final Uint8List pngBytes;
  final File file;
  final int jpgQuality;

  WriteImage(this.pngBytes, this.file, this.jpgQuality);

  @override
  Future<String> job() async {
    var cruncPerc = '';

    if (file.path.endsWith('.jpg')) {
      final jpg = decodePng(pngBytes)!;
      await file.writeAsBytes(encodeJpg(jpg, quality: jpgQuality));

      // await DiskSize().addFile(file.statSync().size, confGenerateNfts);
    } else {
      await file.writeAsBytes(pngBytes);

      final sizeOriginal = file.statSync().size;

      Process.runSync(
          PngQuant.exePath.path,
          [
            '--speed',
            "11",
            '--force',
            '--skip-if-larger',
            '--ext',
            '.png',
            file.path
          ],
          runInShell: true);

      final sizeCrunched = file.statSync().size;
      cruncPerc =
          ' CRUNCHBY: ${(100 - (100 / sizeOriginal) * sizeCrunched).toStringAsFixed(0)} %';
    }

    // eta.write(nftId, confGenerateNfts,
    //     '${file.path} ${filesize(file.statSync().size)}$cruncPerc');

    return cruncPerc;
  }
}
