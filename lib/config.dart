import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:nftgen/io.dart';
import 'package:nftgen/streamprint.dart';
import 'package:path/path.dart';

/// Generates a config file to generate NFTs.
class Config {
  static final Map<String, dynamic> _project = {
    "layerDir": "PATH SET BY USER",
    "metaDir": "meta",
    "imageDir": "image",
    "rarityDir": "rarity",
    "rarityNftCsv": "rarity_nft.csv",
    "rarityNftPng": "rarity_nft.png",
    "rarityLayersCsv": "rarity_layers.csv",
    "rarityLayersPng": "rarity_layers.png",
    "name": "NAME SET BY USER",
    "generateNfts": 0,
    "cidCode": "<-- Your CID Code-->",
    "layers": []
  };

  static final Map<String, dynamic> _layerEntry = {
    "name": 'LAYER-NAME FROM FOLDER',
    "directory": 'LAYER-DIR FROM FOLDER',
    "probability": 1.0,
    "weights": []
  };

  /// Generates a config file to generate NFTs based on a layers directory,
  /// a factor for weight distribution and the order of layers.
  ///
  /// The factor for weight distribution is used as such:
  /// `pow(item, factor).round()`, with item being the number of the the NFT
  /// between 1...MAX. The default weight factor is `3.0`, use `0.0` for equal
  /// distribution of all images belonging to a layer with a weight of `1` for
  /// each image in a layer.
  static Map<String, dynamic> generate(String name, Directory layersDir,
      {double factorWeights = 3.0, double factorMaxNft = 0.6}) {
    int? generateNfts;
    final layerEntries = [];

    layersDir.listSync().whereType<Directory>().forEach((fse) {
      final layerName = basename(fse.path);
      // final Map<String, dynamic> configEntry = {};
      final Map<String, int> weights = {};

      final layerEntry = json.decode(json.encode(_layerEntry));
      layerEntry["name"] = layerName;
      layerEntry["directory"] = layerName;
      layerEntry["probability"] = 1.0;
      layerEntry["weights"] = weights;

      layerEntries.add(layerEntry);

      final entries = Directory(fse.path).listSync();
      for (var i = 1; i <= entries.length; i++) {
        final FileSystemEntity layerFile = entries.elementAt(i - 1);
        final String layerEntity = basename(layerFile.path);
        final int layerWeight = _weight(i, factorWeights);
        weights.addAll({layerEntity: layerWeight});
      }

      if (generateNfts == null) {
        generateNfts = entries.length;
      } else {
        generateNfts = generateNfts! * entries.length;
      }
    });

    final Map<String, dynamic> project = _project;
    project["layerDir"] = normalize(layersDir.absolute.path);
    project["name"] = name;
    project["generateNfts"] = (generateNfts! * factorMaxNft).toInt();
    project["layers"] = layerEntries;

    return project;
  }

  static int _weight(int item, double factor) {
    if (item == 0) {
      throw 'Item is 0, must be > 1';
    }
    return pow(item, factor).round();
  }

  /// Reads the `cid` code from the config and writes it to all
  /// files in the metadata directory.
  static void updateCidMetadata(File configFile, Directory metaDir,
      {required String cidReplace, required String cidSearch}) {
    final config = Io.readJson(configFile);

    cidReplace = cidReplace.isEmpty ? config['cidCode'] : cidReplace;
    cidSearch = cidSearch.isEmpty ? config['cidCode'] : cidSearch;

    if (cidReplace == cidSearch) {
      StreamPrint.prn(
          "Aboring, Search equals replace: $cidSearch == $cidReplace ");
      return;
    }

    StreamPrint.prn('REPLACING cid "$cidSearch" with "$cidReplace" ...');

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
