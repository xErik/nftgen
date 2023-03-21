import 'dart:io';
import 'dart:math';

import 'package:nftgen/src/shared/stopper.dart';
import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/framework/projectmodel.dart';
import 'package:nftgen/framework/streamprint.dart';
import 'package:path/path.dart';
import 'package:collection/collection.dart';

/// Generates a config file to generate NFTs.
class Project {
  /// Generates a config file to generate NFTs based on a layers directory,
  /// a factor for weight distribution and the order of layers.
  ///
  /// It saves the project file in `projectDir`.
  ///
  /// The factor for weight distribution is used as such:
  /// `pow(item, factor).round()`, with item being the number of the the NFT
  /// between 1...MAX. The default weight factor is `3.0`, use `0.0` for equal
  /// distribution of all images belonging to a layer with a weight of `1` for
  /// each image in a layer.
  static Future<ProjectModel> generate(
      String name, Directory projectDir, Directory layerDir,
      {double factorWeights = 3.0,
      double factorMaxNft = 0.6,
      double factorLayers = 0.5}) async {
    int generateNfts = 0;
    final List<ProjectLayerModel> layerEntries = [];

    final layerDirs = layerDir.listSync().whereType<Directory>().toList();
    layerDirs.sort(((a, b) => compareNatural(a.path, b.path)));

    final layerProbs = _probs(layerDirs.length, factorLayers);

    for (var dirIndex = 0; dirIndex < layerDirs.length; dirIndex++) {
      final singleLayerDir = layerDirs.elementAt(dirIndex);

      final layerDirName = basename(singleLayerDir.path);
      final layerName = layerDirName.replaceAll(RegExp(r'^\d+\.? *'), '');
      final Map<String, int> weights = {};

      // WEIGHTS

      final layerDirEntries =
          Directory(singleLayerDir.path).listSync().whereType<File>().toList();
      layerDirEntries.sort(((a, b) => compareNatural(a.path, b.path)));

      for (var i = 1; i <= layerDirEntries.length; i++) {
        final FileSystemEntity layerFile = layerDirEntries.elementAt(i - 1);
        final String layerEntity = basename(layerFile.path);
        final int layerWeight = _weight(i, factorWeights);
        weights.addAll({layerEntity: layerWeight});
      }

      // GENERATE NFTs

      generateNfts = generateNfts == 0
          ? layerDirEntries.length
          : generateNfts * layerDirEntries.length;
      // LAYER

      layerEntries.add(ProjectLayerModel(layerName, Directory(layerDirName),
          layerProbs.elementAt(dirIndex), weights));
    }

    // PROJECT

    generateNfts = min(10000, (generateNfts * factorMaxNft).toInt());

    final projectModel = ProjectModel.init(
        name, generateNfts, "jpg", 80, 11, layerEntries, layerDir);

    await projectModel.saveToFolder(projectDir);

    return projectModel;
  }

  static int _weight(int item, double factor) {
    if (item == 0) {
      throw 'Item is 0, must be > 1';
    }
    return pow(item, factor).round();
  }

  static List<double> _probs(int length, double factorProbabilities) {
    final probabilityOneUntilIndex = (length * factorProbabilities).toInt();
    final double startProbability = 0.05;
    final probabilityIncreaseSteps = length - probabilityOneUntilIndex;
    final List<double> ret = [];
    double prob = startProbability;

    for (var i = length - 1; i >= 0; i--) {
      // avoid in case of 0.0
      if (i > probabilityIncreaseSteps) {
        ret.add(prob);
        prob = prob + prob;
      } else {
        ret.add(1.0);
      }
    }
    return ret.reversed.toList();
  }

  /// Reads the `cid` code from the config and writes it to all
  /// files in the metadata directory.
  static Future updateCidMetadata(Directory projectDir,
      {required String cidReplace, required String cidSearch}) async {
    // final config = Io.readJson(configFile);

    final ProjectModel model = await ProjectModel.loadFromFolder(projectDir);
    // final File configFile = Io.getProject(projectDir);
    final Directory metaDir = model.metaDir;

    cidReplace = cidReplace.isEmpty ? model.cidCode : cidReplace;
    cidSearch = cidSearch.isEmpty ? model.cidCode : cidSearch;

    if (cidReplace == cidSearch) {
      StreamPrint.prn(
          "Exiting, search equals replace: $cidSearch == $cidReplace ");
      return;
    }

    StreamPrint.prn('REPLACING cid "$cidSearch" with "$cidReplace" ...');

    if (model.cidCode != cidReplace) {
      model.cidCode = cidReplace;
      await model.saveToFolder(projectDir);
    }

    final entries = metaDir.listSync();

    for (var entry in entries) {
      Stopper.assertNotStopped();
      final file = File(entry.path);
      final json = await Io.readJson(file);
      json['image'] =
          json['image']!.toString().replaceAll(cidSearch, cidReplace);
      await Io.writeJson(file, json);
    }
  }
}
