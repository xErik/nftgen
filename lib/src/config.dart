import 'dart:io';
import 'dart:math';

import 'package:nft_generate/src/shared/io.dart';
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
  static Map<String, dynamic> generate(Directory layersDir,
      {double factor = 3.0, List<String> order = const []}) {
    int? maxNfts;
    final layerEntries = [];

    layersDir.listSync().forEach((fse) {
      if (fse is Directory) {
        final layerName = basename(fse.path);
        final Map<String, dynamic> configEntry = {};
        final Map<String, int> weights = {};

        configEntry.addAll({
          "name": layerName,
          "directory": layerName,
          "enabled": 1.0,
          "weights": weights
        });
        layerEntries.add(configEntry);

        final entries = Directory(fse.path).listSync();
        for (var i = 1; i <= entries.length; i++) {
          final file = entries.elementAt(i - 1);
          final layerEntity = basename(file.path);
          final layerWeight = _weight(i, factor);
          weights.addAll({layerEntity: layerWeight});
        }

        if (maxNfts == null) {
          maxNfts = entries.length;
        } else {
          maxNfts = maxNfts! * entries.length;
        }
      }
    });

    if (order.isNotEmpty) {
      final tmp = [];
      for (var layerName in order) {
        tmp.add(layerEntries.firstWhere((e) => e["name"] == layerName));
      }
      layerEntries.clear();
      layerEntries.addAll(tmp);
    }

    final Map<String, dynamic> config = {};
    config.addAll({
      "maxNftspossible": maxNfts!,
      "maxNfts": maxNfts!,
      "cidCode": "<-- Your CID Code-->",
      "layers": layerEntries
    });

    return config;
  }

  static int _weight(int item, double factor) {
    if (item == 0) {
      throw 'Item is 0, must be > 1';
    }
    return pow(item, factor).round();
  }

  /// Reads the `cid` code from the config and writes it to all
  /// files in the metadata directory.
  static void setCidMetadata(File configFile, Directory metaDir,
      {String cidReplace = "", String cidSearch = ""}) {
    final config = Io.readJson(configFile);

    cidReplace = cidReplace.isEmpty ? config['cidCode'] : cidReplace;
    cidSearch = cidSearch.isEmpty ? config['cidCode'] : cidSearch;

    if (cidReplace == cidSearch) {
      print("Aboring, Search equals replace: $cidSearch == $cidReplace ");
      return;
    }

    print('REPLACING cid "$cidSearch" with "$cidReplace" ...');

    if (config['cidCode'] != cidReplace) {
      config['cidCode'] = cidReplace;
      Io.writeJson(configFile, config);
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
