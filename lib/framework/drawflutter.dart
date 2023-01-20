import 'dart:io';
import 'dart:typed_data';

import 'dart:ui';

import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/src/shared/stopper.dart';

class DrawFlutter extends DrawBase {
  @override
  Future<Uint8List> draw(int width, int height, List<File> imageFiles) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(
        recorder,
        Rect.fromPoints(
            Offset(0.0, 0.0), Offset(width.toDouble(), height.toDouble())));

    for (var imageFile in imageFiles) {
      Stopper.assertNotStopped();
      // final img = await cacheImage.getImage(imageFile);

      var codec = await instantiateImageCodec(imageFile.readAsBytesSync());
      var frame = await codec.getNextFrame();
      final img = frame.image;
      canvas.drawImage(img, Offset(0, 0), Paint());
    }

    final picture = recorder.endRecording();

    Image img = await picture.toImage(width, height);
    final ByteData? pngBytes =
        await img.toByteData(format: ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }
}
