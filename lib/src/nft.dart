import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:filesize/filesize.dart';
import 'package:humanize_big_int/humanize_big_int.dart';
import 'package:isolate_pool_2/isolate_pool_2.dart';
import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/framework/drawdart.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:nftgen/src/nft/writeimagejob.dart';
import 'package:nftgen/src/shared/disksize.dart';
import 'package:nftgen/src/shared/stopper.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:path/path.dart';
import 'package:universal_disk_space/universal_disk_space.dart';
// import 'package:pool/pool.dart';

import 'nft/cachefile.dart' as nft;
import 'nft/cache.dart';
import 'nft/dna.dart';
import 'shared/io.dart';

import 'package:image/image.dart' as ig;

/// Generates NFTs and metadata
class Nft {
  /// Generates metadata based on a config file and
  /// a directory for metadata output.
  static Future generateMeta(ProjectModel projectModel, int size) async {
    final eta = Eta();
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

      await Io.writeJson(File(fileMeta), generated[nftId]!);

      if (nftId == 1 || nftId == generateNfts || nftId % 100 == 0) {
        eta.write(nftId, generateNfts,
            '$fileMeta DUBS: ${humanizeInt(doubletCount)}');
      }
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
      [DrawBase? drawService,
      bool isWriteJpg = true,
      int jpqQuality = 50]) async {
    final etaMain = Eta();
    final sep = Platform.pathSeparator;
    final ProjectModel model = await ProjectModel.loadFromFolder(projectDir);
    final confLayers = model.layers;
    final canvasService = drawService ?? DrawDart();
    final futures = <Future>[];

    final writePool = IsolatePool(max(Platform.numberOfProcessors - 2, 2));
    await writePool.start();

    bool isStopped = false;

    DiskSize().resetAll();

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

    try {
      for (var nftId = 1; nftId <= confGenerateNfts; nftId++) {
        try {
          Stopper.assertNotStopped();
        } catch (_) {
          isStopped = true;
        }

        if (isStopped == true) {
          print('STOPPED!');
          break;
        }

        final eta = Eta(etaMain.start);

        imageFiles.clear();

        final metaJson = await Io.readJson(
            File('${metaDir.path + sep + nftId.toString()}.json'));

        for (var attribute in metaJson['attributes']) {
          final String nftType = attribute['trait_type'];
          final String nftValue = attribute['value'];

          imageFiles.add(
              cacheFile.getFile(nftType, nftValue, layersDir.path, confLayers));
        }

        final file = File(
            '${imagesDir.path}${Platform.pathSeparator}$nftId.${isWriteJpg ? "jpg" : "png"}');
        final Uint8List pngBytes = await canvasService.draw(
            nftSize["width"]!, nftSize["height"]!, imageFiles);

        final job = WriteImage(pngBytes.buffer.asUint8List(), file, jpqQuality);

        // print('ADDING job ...');

        final future = writePool.scheduleJob(job);

        future.then((cruncPerc) async {
          // print(' XXX $cruncPerc');
          try {
            await DiskSize().addFile(file.statSync().size, confGenerateNfts);
          } catch (e) {
            // print('EXX: $e');
            isStopped = true;
          }
          eta.write(nftId, confGenerateNfts,
              '${file.path} ${filesize(file.statSync().size)}$cruncPerc');
        }, onError: (a) {
          // print("CAUGHT WHILE ADDING JOBS: ${a.toString()}");
          isStopped = true;
        });

        futures.add(future);
      }
      // print('WAIT');
      await Future.wait(futures, eagerError: true);
      // } on NftStopException catch (e) {
      //   print('STOPPED EXC: $e');
      //   rethrow;
      // } on NftNotEnoughFreespaceException catch (e) {
      //   print('DISK SPACE EXC: $e');
      //   // rethrow;
      // } on NftException catch (e) {
      //   print('GENERIC NFT EXC: $e');
      //   rethrow;
    } catch (e) {
      print('EXC: $e');
      rethrow;
    } finally {
      try {
        // print('STOP ISO');
        StreamPrint.prn('Stopping NFT generation ...');
        writePool.stop();
      } catch (e) {
        // ignore
      }
    }
  }

  /// Returns the width and height of the first image found in `layersDir`:
  /// `{"width": <WIDTH>, "height": <HEIGHT>}`
  static Future<Map<String, int>> getImageSize(Directory layersDir) async {
    final path = Directory(layersDir.listSync()[0].path).listSync()[0].path;
    final image = await ig.decodePngFile(path);
    return {"width": image!.width, "height": image.height};
  }
}
