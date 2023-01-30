import 'dart:io';
import 'dart:typed_data';

import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/src/shared/stopper.dart';
import 'package:image/image.dart' as ig;

/// Draws NFTs using the pure Dart `image` package.
class DrawDart extends DrawBase {
  /// Draws an NFT.
  @override
  Future<Uint8List> draw(int width, int height, List<File> imageFiles) async {
    final canvas = ig.Image(width: width, height: height);

    for (var imageFile in imageFiles) {
      Stopper.assertNotStopped();
      ig.compositeImage(canvas, (await ig.decodeImageFile(imageFile.path))!);
    }

    return ig.encodePng(canvas);
  }
}
