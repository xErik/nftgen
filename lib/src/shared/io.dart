import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/framework/streamprint.dart';

// static Future<Map<String, dynamic>> _parseInBackground() async {
//   final p = ReceivePort();
//   await Isolate.spawn(_writeJson, p.sendPort);
//   return await p.first as Map<String, dynamic>;
// }

//

// JsonEncoder encoder = JsonEncoder.withIndent('  ', (val) {
//   if (val is Directory) {
//     return val.absolute.path;
//   }
//   if (val is File) {
//     return val.absolute.path;
//   }
//   StreamPrint.err("Stringifying value with type: $val");
//   throw val.toString();
// });
// String prettyprint = encoder.convert(config);
// targetFile.parent.createSync(recursive: true);
// targetFile.writeAsStringSync(prettyprint);

class CustomObject {
  File file;
  Map<String, dynamic> config;
  SendPort sendPort;

  CustomObject(this.file, this.config, this.sendPort);
}

/// Io helper class.
class Io {
  static final sep = Platform.pathSeparator;
  static final String projectJson = 'project.json';

  static final JsonEncoder encoder = JsonEncoder.withIndent('  ', (val) {
    if (val is Directory) {
      return val.absolute.path;
    }
    if (val is File) {
      return val.absolute.path;
    }
    StreamPrint.err("Stringifying value with type: $val");
    throw val.toString();
  });

  static void writeJson(File targetFile, Map<String, dynamic> config) {
    String prettyprint = encoder.convert(config);
    targetFile.parent.createSync(recursive: true);
    targetFile.writeAsStringSync(prettyprint);
  }

  /// Write a JSON file.
  // static Future writeJson(File targetFile, Map<String, dynamic> config) async {
  //   final ReceivePort receivePort = ReceivePort();
  //   final obj = CustomObject(targetFile, config, receivePort.sendPort);
  //   await Isolate.spawn(_writeJson, obj);
  //   await receivePort.first;
  // }

  // static void _writeJson(CustomObject obj) async {
  //   final targetFile = obj.file;
  //   final config = obj.config;

  //   String prettyprint = encoder.convert(config);
  //   await targetFile.parent.create(recursive: true);
  //   await targetFile.writeAsString(prettyprint);

  //   obj.sendPort.send(targetFile.path);
  // }

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
    return File(File(workDir.path + sep + projectJson).path);
  }

  // -----------------------------------------------------------------

  static bool checkProjectFolderExits(Directory projectDir) {
    final projectFile = getProject(projectDir);
    return projectFile.existsSync();
  }

  /// throws NftFileNotFoundException if false.
  static void assertExistsFile(File projectFile) {
    // print("projectFile.existsSync() ${projectFile.existsSync()}");
    if (projectFile.existsSync() == false) {
      throw NftFileNotFoundException(
          "File does not exist: ${projectFile.path} ");
    }
  }

  /// throws NftFileNotFoundException if true.
  static void asserExistsNotFile(File projectFile) {
    if (projectFile.existsSync() == true) {
      throw NftFileNotFoundException("File does exist: ${projectFile.path}");
    }
  }

  /// throws NftFolderNotFoundException if false.
  static void assertExistsFolder(Directory metaDir) {
    if (metaDir.existsSync() == false) {
      throw NftFolderNotFoundException(
          "Folder does not exist: ${metaDir.path}");
    }
  }

  /// throws NftFolderNotFoundException if true.
  static void assertExistsNotFolder(Directory metaDir) {
    if (metaDir.existsSync() == true) {
      throw NftFolderNotFoundException("Folder does exist: ${metaDir.path} ");
    }
  }
}
