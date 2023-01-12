import 'dart:convert';
import 'dart:io';

import 'package:nftgen/streamprint.dart';

/// Io helper class.
class Io {
  static final sep = Platform.pathSeparator;
  static final String projectJson = 'project.json';

  /// Write a JSON file.
  static void writeJson(File json, Map<String, dynamic> config) {
    JsonEncoder encoder = JsonEncoder.withIndent('  ', (val) {
      if (val is Directory) {
        return val.absolute.path;
      }
      if (val is File) {
        return val.absolute.path;
      }
      StreamPrint.err("Stringifying value with type: $val");
      throw val.toString();
    });
    String prettyprint = encoder.convert(config);
    json.parent.createSync(recursive: true);
    json.writeAsStringSync(prettyprint);
  }

  /// Reads a JSON file.
  static Map<String, dynamic> readJson(File json) {
    final input = json.readAsStringSync();
    return jsonDecode(input);
  }

  /// Saves `sortedEntries` to `csvFile`.
  static void writeCsv(
      List<MapEntry<String, double>> sortedEntries, File csvFile) {
    var outCsv = '';

    for (var entry in sortedEntries) {
      final String key = entry.key;
      final double count = entry.value;
      // final String perc = attributeCountPercentage[entry.key]!.toStringAsFixed(2);
      outCsv += '$key, $count\n';
    }

    csvFile.parent.createSync(recursive: true);
    csvFile.writeAsStringSync(outCsv);
  }

  /// Returns JSON files: ending in `.json` and not starting
  /// with an underscore `_`.
  static List<FileSystemEntity> getJsonFiles(Directory jsonDir) {
    return jsonDir
        .listSync()
        .where(
            (m) => m.path.endsWith('.json') && m.path.startsWith('_') == false)
        .toList();
  }

  /// Returns JSON files: ending in `.json` and not starting
  /// with an underscore `_`.
  static List<Directory> getFolders(Directory dir) {
    return dir
        .listSync()
        .whereType<Directory>()
        .map((e) => Directory(e.path))
        .toList();
  }

  static bool existsProject(workDir) {
    return File(workDir.path + sep + projectJson).existsSync();
  }

  static File getProject(workDir) {
    return File(workDir.path + sep + projectJson);
  }

  // -----------------------------------------------------------------

  static Map<String, dynamic> mapJson(Directory projectDir) {
    File projectFile =
        File('${projectDir.path}${Platform.pathSeparator}${Io.projectJson}');

    checkProjectFileExit(projectFile);

    Map<String, dynamic> projectJson = Io.readJson(projectFile);

    return {
      "name": projectJson['name'],
      // "factor": projectJson['weightsFactor'],
      "cidSearch": projectJson["cidCode"],
      "metaDir": Directory(projectDir.path + Io.sep + projectJson['metaDir']),
      "layerDir": Directory(projectJson['layerDir']), // NOT ON PROJECT!
      "imageDir": Directory(projectDir.path + Io.sep + projectJson['imageDir']),
      "rarityDir":
          Directory(projectDir.path + Io.sep + projectJson['rarityDir']),
      "csvNftFile": File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityNftCsv"]),
      "csvLayersFile": File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityLayersCsv"]),
      "pngNftFile": File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityNftPng"]),
      "pngLayersFile": File(projectDir.path +
          Io.sep +
          projectJson['rarityDir'] +
          Io.sep +
          projectJson["rarityLayersPng"]),
    };
  }

  static void checkProjectFileExit(File projectFile) {
    if (projectFile.existsSync() == false) {
      StreamPrint.prn("Exiting, file does not exist: ${projectFile.path} ");
      exit(64);
    }
  }

  static void checkFolderExists(Directory metaDir) {
    if (metaDir.existsSync() == false) {
      StreamPrint.prn("Exiting, folder does not exist: ${metaDir.path} ");
      exit(64);
    }
  }
}
