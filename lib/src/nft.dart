import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/framework/drawdart.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:nftgen/src/shared/stopper.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:path/path.dart';

import 'nft/cachefile.dart' as nft;
import 'nft/cache.dart';
import 'nft/dna.dart';
import 'shared/io.dart';

import 'package:image/image.dart' as ig;

/// Generates NFTs and metadata
class Nft {
  /// Generates metadata based on a config file and
  /// a directory for metadata output.
  static Future<void> generateMeta(ProjectModel projectModel, int size) async {
    final eta = Eta()..start();
    final rnd = Random.secure();
    final cache = CacheLayerFileWeights(rnd);
    final dna = Dna();
    final name = projectModel.name;
    final layers = projectModel.layers;
    final metaDir = projectModel.metaDir;
    int generateNfts = size > -1 ? size : projectModel.generateNfts;
    int doubletCount = 0;

    generateNfts = min(10000, generateNfts);

    if (metaDir.existsSync()) {
      metaDir.deleteSync(recursive: true);
    }
    metaDir.createSync(recursive: true);

    final Map<int, Map<String, dynamic>> generated = {};

    for (var nftId = 1; nftId <= generateNfts; nftId++) {
      Stopper.assertNotStopped();
      String nftDna = '';
      final List<Map<String, String>> attributes = [];

      while (nftDna.isEmpty) {
        attributes.clear();
        nftDna = '';

        for (var layer in layers) {
          final String layerName = layer.name;
          final double layerProbability = layer.probability;
          final Map<String, int> layerWeights = layer.weights;

          if (layerProbability == 0.0 || rnd.nextDouble() >= layerProbability) {
            continue;
          }

          final layerFile =
              cache.getLayerFileByRandomWeight(layerName, layerWeights);
          final layerValue = layerFile.split('.')[0];

          attributes.add({"trait_type": layerName, "value": layerValue});
        }

        nftDna = dna.getDna(attributes);

        if (dna.hasDna(nftDna)) {
          doubletCount++;
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

      final fileMeta =
          normalize('${metaDir.path}${Platform.pathSeparator}$nftId.json');
      Io.writeJson(File(fileMeta), generated[nftId]!);

      eta.write(
          nftId, generateNfts, '$fileMeta DUBS: ${humanizeInt(doubletCount)}');
    }
  }

  /// Generates NFTs based on a config file, a directory containing
  /// layers in sub-directories, a directory for image output,
  /// based on a directory holding metadata files.
  ///
  /// Number of NFTs generated pririty:
  /// 1. Number of metadata files in meta-dir
  /// 2. Number of `size` parameter
  /// 3. Number specified in `project.json`
  static Future<void> generateNft(Directory projectDir, int size,
      Directory layersDir, Directory imagesDir, Directory metaDir,
      [DrawBase? drawService]) async {
    final eta = Eta()..start();
    final sep = Platform.pathSeparator;
    final ProjectModel model = ProjectModel.loadFromFolder(projectDir);
    final confLayers = model.layers;
    final canvasService = drawService ?? DrawDart();

    StreamPrint.prn('Using draw service: ${canvasService.runtimeType}');

    int confGenerateNfts = size > -1 ? size : model.generateNfts;
    confGenerateNfts = min(confGenerateNfts, metaDir.listSync().length);

    final nftSize = await getImageSize(layersDir);
    final List<File> imageFiles = [];
    final cacheFile = nft.CacheFile();

    if (imagesDir.existsSync()) {
      imagesDir.deleteSync(recursive: true);
    }
    imagesDir.createSync(recursive: true);

    for (var nftId = 1; nftId <= confGenerateNfts; nftId++) {
      Stopper.assertNotStopped();
      imageFiles.clear();

      final metaJson =
          Io.readJson(File('${metaDir.path + sep + nftId.toString()}.json'));

      for (var attribute in metaJson['attributes']) {
        final String nftType = attribute['trait_type'];
        final String nftValue = attribute['value'];

        imageFiles.add(
            cacheFile.getFile(nftType, nftValue, layersDir.path, confLayers));
      }

      // -----------------------------------------------------
      // IMAGE
      // -----------------------------------------------------

      // for (var imageFile in imageFiles) {
      //   Stopper.assertNotStopped(StopCommand.nft);
      //   ig.compositeImage(canvas, (await ig.decodeImageFile(imageFile.path))!);
      //   // ig.compositeImage(canvas, await cacheImage.getImage(imageFile));
      // }

      // var fileImage = '${imagesDir.path}${Platform.pathSeparator}$nftId.png';
      // File(fileImage).writeAsBytesSync(ig.encodePng(canvas));

// ----------------------------------

      // final recorder = ui.PictureRecorder();
      // final canvas = Canvas(
      //     recorder,
      //     Rect.fromPoints(
      //         Offset(0.0, 0.0),
      //         Offset(nftSize["width"]!.toDouble(),
      //             nftSize["height"]!.toDouble())));

      // for (var imageFile in imageFiles) {
      //   Stopper.assertNotStopped();
      //   // final img = await cacheImage.getImage(imageFile);

      //   var codec = await ui.instantiateImageCodec(imageFile.readAsBytesSync());
      //   var frame = await codec.getNextFrame();
      //   final img = frame.image;
      //   canvas.drawImage(img, Offset(0, 0), Paint());
      // }

      // final picture = recorder.endRecording();

      // ui.Image img =
      //     await picture.toImage(nftSize["width"]!, nftSize["height"]!);
      // final ByteData? pngBytes =
      //     await img.toByteData(format: ui.ImageByteFormat.png);

// ----------------------------------

      final fileImage = '${imagesDir.path}${Platform.pathSeparator}$nftId.png';
      final pngBytes = await canvasService.draw(
          nftSize["width"]!, nftSize["height"]!, imageFiles);

      File(fileImage).writeAsBytesSync(pngBytes.buffer.asUint8List());

      // -----------------------------------------------------
      // PRINT an ETA
      // -----------------------------------------------------

      eta.write(nftId, confGenerateNfts, fileImage);
    }
  }

  // static Future<ui.Image> _loadImage(File image, CacheImage cacheImage) async {
  //   final bytes = await cacheImage.getImage(imageFile);
  //   var codec = await ui.instantiateImageCodec(image.readAsBytesSync());
  //   var frame = await codec.getNextFrame();
  //   return frame.image;
  // }

  /// Returns the width and height of the first image found in `layersDir`:
  /// `{"width": <WIDTH>, "height": <HEIGHT>}`
  static Future<Map<String, int>> getImageSize(Directory layersDir) async {
    // final layers = layersDir.listSync();
    // if(layers)
    print(layersDir.path);

    final path = Directory(layersDir.listSync()[0].path).listSync()[0].path;

    // final path = Directory(layersDir.listSync()[0].path).listSync()[0].path;
    final image = await ig.decodePngFile(path);
    return {"width": image!.width, "height": image.height};
  }
}
