import 'dart:io';
import 'dart:math';

import 'package:nftgen/src/shared/io.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/public/streamprint.dart';
import 'package:path/path.dart';

/// Generates a config file to generate NFTs.
class Config {
  /// Generates a config file to generate NFTs based on a layers directory,
  /// a factor for weight distribution and the order of layers.
  ///
  /// The factor for weight distribution is used as such:
  /// `pow(item, factor).round()`, with item being the number of the the NFT
  /// between 1...MAX. The default weight factor is `3.0`, use `0.0` for equal
  /// distribution of all images belonging to a layer with a weight of `1` for
  /// each image in a layer.
  static ProjectModel generate(String name, Directory layersDir,
      {double factorWeights = 3.0, double factorMaxNft = 0.6}) {
    int generateNfts = 0;
    final List<ProjectLayerModel> layerEntries = [];

    layersDir.listSync().whereType<Directory>().forEach((fse) {
      final layerName = basename(fse.path);
      final Map<String, int> weights = {};

      // WEIGHTS

      final entries = Directory(fse.path).listSync();
      for (var i = 1; i <= entries.length; i++) {
        final FileSystemEntity layerFile = entries.elementAt(i - 1);
        final String layerEntity = basename(layerFile.path);
        final int layerWeight = _weight(i, factorWeights);
        weights.addAll({layerEntity: layerWeight});
      }

      // GENERATE NFTs

      generateNfts =
          generateNfts == 0 ? entries.length : generateNfts * entries.length;

      // LAYER

      layerEntries.add(
          ProjectLayerModel(layerName, Directory(layerName), 1.0, weights));
    });

    // PROJECT

    return ProjectModel.init(
        name, generateNfts, factorMaxNft, layerEntries, layersDir);
  }

  static int _weight(int item, double factor) {
    if (item == 0) {
      throw 'Item is 0, must be > 1';
    }
    return pow(item, factor).round();
  }

  /// Reads the `cid` code from the config and writes it to all
  /// files in the metadata directory.
  static void updateCidMetadata(Directory projectDir,
      {required String cidReplace, required String cidSearch}) {
    // final config = Io.readJson(configFile);

    final ProjectModel model = ProjectModel.loadFromFolder(projectDir);
    final File configFile = Io.getProject(projectDir);
    final Directory metaDir = model.metaDir;

    cidReplace = cidReplace.isEmpty ? model.cidCode : cidReplace;
    cidSearch = cidSearch.isEmpty ? model.cidCode : cidSearch;

    if (cidReplace == cidSearch) {
      StreamPrint.prn(
          "Aboring, search equals replace: $cidSearch == $cidReplace ");
      return;
    }

    StreamPrint.prn('REPLACING cid "$cidSearch" with "$cidReplace" ...');

    if (model.cidCode != cidReplace) {
      model.cidCode = cidReplace;
      model.saveToFolder(projectDir);
    }

    final entries = metaDir.listSync();

    for (var entry in entries) {
      final file = File(entry.path);
      final json = Io.readJson(file);
      json['image'] =
          json['image']!.toString().replaceAll(cidSearch, cidReplace);
      Io.writeJson(file, json);
    }
  }
}
