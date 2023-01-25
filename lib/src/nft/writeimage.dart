import 'dart:io';
import 'dart:typed_data';

import 'package:filesize/filesize.dart';
import 'package:image/image.dart';
import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/src/shared/disksize.dart';
import 'package:nftgen/src/shared/pngquant.dart';
import 'package:nftgen/src/shared/eta.dart';

class WriteImage extends PooledJob {
  final Eta eta;
  final int nftId;
  final int confGenerateNfts;
  final Uint8List pngBytes;
  final File file;
  final int jpgQuality;
  final String returnMessage;

  WriteImage(this.eta, this.nftId, this.confGenerateNfts, this.pngBytes,
      this.file, this.jpgQuality, this.returnMessage);

  @override
  Future job() async {
    var cruncPerc = '';

    if (file.path.endsWith('.jpg')) {
      final jpg = decodePng(pngBytes)!;
      await file.writeAsBytes(encodeJpg(jpg, quality: jpgQuality));

      await DiskSize().addFile(file.statSync().size, confGenerateNfts);
    } else {
      await file.writeAsBytes(pngBytes);

      final sizeOriginal = file.statSync().size;

      final p = Process.runSync(
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

      await DiskSize().addFile(sizeCrunched, confGenerateNfts);
    }

    eta.write(nftId, confGenerateNfts,
        '${file.path} ${filesize(file.statSync().size)}$cruncPerc');
  }
}
