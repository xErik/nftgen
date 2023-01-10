import 'dart:io';
import 'dart:math';

import 'config/cache.dart';
import 'config/dna.dart';
import 'shared/io.dart';

import 'package:image/image.dart' as ig;

/// Generates NFTs.
class Nft {
  /// Generates NFTs based on a config file, a directory containing
  /// layers in sub-directories, a directory for image output,
  /// a directory for metadata output.
  static void generate(File configFile, Directory layersDir,
      Directory imagesDir, Directory metaDir,
      {bool metaOnly = false}) async {
    final rnd = Random.secure();
    final cache = Cache(rnd);
    final dna = Dna();
    final json = Io.readJson(configFile);
    final layers = json['layers'];
    final maxNfts = json['maxNfts'].toInt();

    final nftSize = await getImageSize(layersDir);

    // print("Size of layers ${nftSize['width']} x ${nftSize["height"]}");

    imagesDir.deleteSync(recursive: true);
    metaDir.deleteSync(recursive: true);
    imagesDir.createSync(recursive: true);
    metaDir.createSync(recursive: true);

    final Map<int, Map<String, dynamic>> generated = {};

    for (var nftId = 1; nftId <= maxNfts; nftId++) {
      String nftDna = '';
      final List<Map<String, String>> attributes = [];
      final List<File> imageFiles = [];

      while (nftDna.isEmpty) {
        attributes.clear();
        imageFiles.clear();
        nftDna = '';

        for (var layer in layers) {
          final String layerName = layer['name'] as String;
          final Directory layerDir = Directory(layer['directory'] as String);
          final double layerProbability = layer['probability'];
          final Map<String, int> layerWeights = Map.from(layer['weights']);

          if (layerProbability == 0.0 || rnd.nextDouble() >= layerProbability) {
            continue;
          }

          final layerFile = cache.getRandomWeight(layerName, layerWeights);
          final layerValue = layerFile.split('.')[0];

          attributes.add({"trait_type": layerName, "value": layerValue});

          imageFiles.add(File(layersDir.path +
              Platform.pathSeparator +
              layerDir.path +
              Platform.pathSeparator +
              layerFile));
        }

        nftDna = dna.getDna(attributes);

        if (dna.hasDna(nftDna)) {
          // print('EXISTS: $nftDna');
          nftDna = '';
        }
      }

      dna.addDna(nftDna);

      // -----------------------------------------------------
      // IMAGE
      // -----------------------------------------------------
      if (metaOnly == false) {
        final canvas =
            ig.Image(width: nftSize['width']!, height: nftSize["height"]!);

        for (var imageFile in imageFiles) {
          final bytes = await ig.decodeImageFile(imageFile.path);
          ig.compositeImage(canvas, bytes!);
        }

        var fileImage = '${imagesDir.path}${Platform.pathSeparator}$nftId.png';
        print('${nftId.toString().padLeft(4, " ")} $fileImage $nftDna');
        File(fileImage).writeAsBytesSync(ig.encodePng(canvas));
      }
      // -----------------------------------------------------
      // META
      // -----------------------------------------------------

      generated.addAll({
        nftId: {
          "name": "$nftId",
          "description": "",
          "image": "ipfs://<-- Your CID Code-->/$nftId.png",
          "dna": nftDna,
          "attributes": attributes
        }
      });

      var fileMeta = '${metaDir.path}${Platform.pathSeparator}$nftId.json';
      print('${nftId.toString().padLeft(4, " ")} $fileMeta $nftDna');
      Io.writeJson(File(fileMeta), generated[nftId]!);
    }
  }

  /// Returns the width and height of the first image found in `layersDir`:
  /// `{"width": <WIDTH>, "height": <HEIGHT>}`
  static Future<Map<String, int>> getImageSize(Directory layersDir) async {
    final path = Directory(layersDir.listSync()[0].path).listSync()[0].path;

    final forSize = await ig.decodePngFile(path);
    return {"width": forSize!.width, "height": forSize.height};
  }
}
