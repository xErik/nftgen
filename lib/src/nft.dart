import 'dart:io';
import 'dart:math';

import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/src/shared/eta.dart';

import 'nft/cache.dart' as nft;
import 'config/cache.dart';
import 'config/dna.dart';
import 'shared/io.dart';

import 'package:image/image.dart' as ig;

/// Generates NFTs and metadata
class Nft {
  /// Generates metadata based on a config file and
  /// a directory for metadata output.
  static void generateMeta(File configFile, Directory metaDir) async {
    final eta = Eta()..start();
    final rnd = Random.secure();
    final cache = Cache(rnd);
    final dna = Dna();
    final json = Io.readJson(configFile);
    final name = json['name'];
    final layers = json['layers'];
    final generateNfts = json['generateNfts'].toInt();

    if (metaDir.existsSync()) {
      metaDir.deleteSync(recursive: true);
    }
    metaDir.createSync(recursive: true);

    final Map<int, Map<String, dynamic>> generated = {};

    for (var nftId = 1; nftId <= generateNfts; nftId++) {
      String nftDna = '';
      final List<Map<String, String>> attributes = [];

      while (nftDna.isEmpty) {
        attributes.clear();
        nftDna = '';

        for (var layer in layers) {
          final String layerName = layer['name'] as String;
          // final Directory layerDir = Directory(layer['directory'] as String);
          final double layerProbability = layer['probability'];
          final Map<String, int> layerWeights = Map.from(layer['weights']);

          if (layerProbability == 0.0 || rnd.nextDouble() >= layerProbability) {
            continue;
          }

          final layerFile = cache.getRandomWeight(layerName, layerWeights);
          final layerValue = layerFile.split('.')[0];

          attributes.add({"trait_type": layerName, "value": layerValue});
        }

        nftDna = dna.getDna(attributes);

        if (dna.hasDna(nftDna)) {
          // print('EXISTS: $nftDna');
          nftDna = '';
        }
      }

      dna.addDna(nftDna);

      // -----------------------------------------------------
      // META
      // -----------------------------------------------------

      generated.addAll({
        nftId: {
          "name": "$name #$nftId",
          "description": "",
          "image": "ipfs://${ProjectModel.cidDefaultCode}/$nftId.png",
          "dna": nftDna,
          "attributes": attributes
        }
      });

      var fileMeta = '${metaDir.path}${Platform.pathSeparator}$nftId.json';
      Io.writeJson(File(fileMeta), generated[nftId]!);

      eta.write(nftId, generateNfts, '$fileMeta ${nftDna.substring(0, 5)}...');
    }
  }

  /// Generates NFTs based on a config file, a directory containing
  /// layers in sub-directories, a directory for image output,
  /// based on a directory holding metadata files.
  static Future<void> generateNft(Directory projectDir, Directory layersDir,
      Directory imagesDir, Directory metaDir) async {
    final eta = Eta()..start();
    final sep = Platform.pathSeparator;
    final ProjectModel model = ProjectModel.loadFromFolder(projectDir);
    final confLayers = model.layers;
    final confGenerateNfts = model.generateNfts;

    final nftSize = await getImageSize(layersDir);
    final List<File> imageFiles = [];
    final canvas =
        ig.Image(width: nftSize['width']!, height: nftSize["height"]!);
    final cache = nft.Cache();

    if (imagesDir.existsSync()) {
      imagesDir.deleteSync(recursive: true);
    }
    imagesDir.createSync(recursive: true);

    for (var nftId = 1; nftId <= confGenerateNfts; nftId++) {
      imageFiles.clear();
      canvas.clear();

      final metaJson =
          Io.readJson(File('${metaDir.path + sep + nftId.toString()}.json'));

      for (var attribute in metaJson['attributes']) {
        final String nftType = attribute['trait_type'];
        final String nftValue = attribute['value'];

        imageFiles
            .add(cache.getFile(nftType, nftValue, layersDir.path, confLayers));
      }

      // -----------------------------------------------------
      // IMAGE
      // -----------------------------------------------------

      for (var imageFile in imageFiles) {
        final bytes = await ig.decodeImageFile(imageFile.path);
        ig.compositeImage(canvas, bytes!);
      }

      var fileImage = '${imagesDir.path}${Platform.pathSeparator}$nftId.png';
      File(fileImage).writeAsBytesSync(ig.encodePng(canvas));

      // -----------------------------------------------------
      // PRINT an ETA
      // -----------------------------------------------------

      eta.write(nftId, confGenerateNfts, fileImage);
    }
  }

  /// Returns the width and height of the first image found in `layersDir`:
  /// `{"width": <WIDTH>, "height": <HEIGHT>}`
  static Future<Map<String, int>> getImageSize(Directory layersDir) async {
    final path = Directory(layersDir.listSync()[0].path).listSync()[0].path;
    final image = await ig.decodePngFile(path);
    // print('SIZE: ' + image.toString());
    return {"width": image!.width, "height": image.height};
    // return {"width": 512, "height": 512};
  }
}
