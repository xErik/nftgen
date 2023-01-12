import 'dart:io';

import 'package:nftgen/io.dart';
import 'package:nftgen/src/shared/streamprint.dart';

abstract class ProjectJson {
  Map<String, dynamic> mapJson(Directory projectDir) {
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

  void checkProjectFileExit(File projectFile) {
    if (projectFile.existsSync() == false) {
      StreamPrint.prn("Exiting, file does not exist: ${projectFile.path} ");
      exit(64);
    }
  }

  void checkFolderExists(Directory metaDir) {
    if (metaDir.existsSync() == false) {
      StreamPrint.prn("Exiting, folder does not exist: ${metaDir.path} ");
      exit(64);
    }
  }
}
