import 'dart:convert';
import 'dart:io';

import 'package:nftgen/public/nftcliexception.dart';
import 'package:nftgen/public/projectmodel.dart';
import 'package:nftgen/public/streamprint.dart';
import 'package:path/path.dart';

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

  static File getProject(Directory workDir) {
    return File(normalize(File(workDir.path + sep + projectJson).path));
  }

  // -----------------------------------------------------------------

  // throws NftCliException if false.
  static bool checkProjectFolderExits(Directory projectDir) {
    final projectFile = getProject(projectDir);
    return projectFile.existsSync();
  }

  /// throws NftCliException if false.
  static void assertExistsFile(File projectFile) {
    // print("projectFile.existsSync() ${projectFile.existsSync()}");
    if (projectFile.existsSync() == false) {
      throw NftCliException("File does not exist: ${projectFile.path} ");
    }
  }

  /// throws NftCliException if true.
  static void asserExistsNotFile(File projectFile) {
    if (projectFile.existsSync() == true) {
      throw NftCliException("File does exist: ${projectFile.path} ");
    }
  }

  /// throws NftCliException if false.
  static void assertExistsFolder(Directory metaDir) {
    if (metaDir.existsSync() == false) {
      throw NftCliException("Folder does not exist: ${metaDir.path} ");
    }
  }

  /// throws NftCliException if true.
  static void assertExistsNotFolder(Directory metaDir) {
    if (metaDir.existsSync() == true) {
      throw NftCliException("Folder does exist: ${metaDir.path} ");
    }
  }
}
