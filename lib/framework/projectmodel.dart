import 'dart:io';

import 'package:nftgen/src/shared/io.dart';
import 'package:path/path.dart';
import 'dart:convert';

/// Part of `config.json`.
class ProjectLayerModel {
  String name;
  Directory directory;
  double probability;
  Map<String, int> weights;

  /// Constructor.
  ProjectLayerModel(this.name, this.directory, this.probability, this.weights);

  // Returns model map representing JSON.
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "directory": directory.path,
      "probability": probability,
      "weights": weights
    };
  }

  // Returns model from JSON.
  static ProjectLayerModel fromJson(Map<String, dynamic> projectLayer) {
    return ProjectLayerModel(
        projectLayer["name"] as String,
        Directory(projectLayer["directory"]),
        projectLayer["probability"] as double,
        Map<String, int>.from(projectLayer["weights"]));
  }
}

/// Represents `config.json`
class ProjectModel {
  String name;
  String cidCode;
  int generateNfts;
  List<ProjectLayerModel> layers;
  Directory layerDir;
  final Directory metaDir;
  final Directory imageDir;
  final Directory rarityDir;
  final File rarityNftCsv;
  final File rarityLayersCsv;
  final File rarityNftPng;
  final File rarityLayersPng;

  /// Constructor.
  ProjectModel(
      this.name,
      this.cidCode,
      this.generateNfts,
      // this.weightsFactor,
      this.layers,
      //
      this.metaDir,
      this.layerDir,
      this.imageDir,
      this.rarityDir,
      this.rarityNftCsv,
      this.rarityLayersCsv,
      this.rarityNftPng,
      this.rarityLayersPng);

  static final cidDefaultCode = "<-- Your CID Code-->";

  /// Returns model with initial values. Some of the model's values are set
  /// to sensible defaults.
  static ProjectModel init(String name, int generateNfts,
      List<ProjectLayerModel> projectLayers, Directory layersDir) {
    return ProjectModel(
      name,
      cidDefaultCode,
      generateNfts,
      projectLayers,
      Directory("meta"),
      Directory(normalize(layersDir.absolute.path)),
      Directory("image"),
      Directory("rarity"),
      File("rarity_nft.csv"),
      File("rarity_layers.csv"),
      File("rarity_nft.png"),
      File("rarity_layers.png"),
    );
  }

  /// throws NftCliException if false.
  static ProjectModel loadFromFolder(Directory projectDir) {
    final projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');

    Io.assertExistsFile(projectFile);

    Map<String, dynamic> projectJson = Io.readJson(projectFile);

    return fromJson(projectJson, projectDir);
  }

  /// throws NftCliException if false.
  static ProjectModel fromJson(
      Map<String, dynamic> projectJson, Directory projectDir) {
    final List<Map<String, dynamic>> layersJson =
        List<Map<String, dynamic>>.from(projectJson['layers']);

    final List<ProjectLayerModel> layers = layersJson
        .map((layerJson) => ProjectLayerModel.fromJson(layerJson))
        .toList();

    return ProjectModel(
      projectJson['name'] as String,
      projectJson["cidCode"] as String,
      projectJson["generateNfts"] as int,
      // projectJson['weightsFactor'],
      // projectJson['layers'],
      layers,
      //
      Directory(projectDir.path + Io.sep + projectJson['metaDir']),
      Directory(projectJson['layerDir']), // NOT IN PROJECT!
      Directory(projectDir.path + Io.sep + projectJson['imageDir']),
      Directory(projectDir.path + Io.sep + projectJson['rarityDir']),
      File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityNftCsv"]),
      File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityLayersCsv"]),
      File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityNftPng"]),
      File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityLayersPng"]),
    );
  }

  void saveToFolder(Directory projectDir) {
    final projectFile = Io.getProject(projectDir);
    Io.writeJson(projectFile, toJson());
  }

  /// Returns empty model.
  static ProjectModel empty() {
    return ProjectModel('', '', 0, [], Directory(''), Directory(''),
        Directory(''), Directory(''), File(''), File(''), File(''), File(''));
  }

  /// Returns whether this model is empty by testing emptiness of `name`.
  bool isEmpty() {
    return name.isEmpty;
  }

  /// Adds layer to model.
  addLayer(String name, Directory directory, double probability,
      Map<String, int> weights) {
    final layer = ProjectLayerModel(name, directory, probability, weights);
    layers.add(layer);
  }

  // Returns map of model representing JSON.
  Map<String, dynamic> toJson() {
    final layersJson = [];
    for (var layer in layers) {
      layersJson.add(layer.toJson());
    }

    return {
      "name": name,
      "cidCode": cidCode,
      "generateNfts": generateNfts,
      // "weightsFactor": weightsFactor,
      "layers": layersJson,
      //
      "metaDir": basename(metaDir.path),
      "layerDir": layerDir.path, // NOT IN PROJECT!
      "imageDir": basename(imageDir.path),
      "rarityDir": basename(rarityDir.path),
      "rarityNftCsv": basename(rarityNftCsv.path),
      "rarityLayersCsv": basename(rarityLayersCsv.path),
      "rarityNftPng": basename(rarityNftPng.path),
      "rarityLayersPng": basename(rarityLayersPng.path),
    };
  }

  /// Convenience method.
  String toPrettyJson() {
    var encoder = JsonEncoder.withIndent("  ");
    return encoder.convert(toJson());
  }

  int getLayerCount() {
    return layers.length;
  }

  int getFileCount() {
    int files = 0;
    for (var layer in layers) {
      files += layer.weights.length;
    }
    return files;
  }

  int getCombinationCount() {
    int combinations = 0;
    for (var layer in layers) {
      combinations = combinations == 0
          ? layer.weights.length
          : combinations * layer.weights.length;
    }
    return combinations;
  }
}
