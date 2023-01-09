import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as ig;

void main() {
  final sep = Platform.pathSeparator;
  final assets = Directory('assets');
  final layersDir = Directory('${assets.path}${sep}layers');
  final genImagesDir = Directory('${assets.path}${sep}images');
  final genMetaDir = Directory('${assets.path}${sep}meta');

  final Map<String, dynamic> config = genConfig(layersDir, 3);

  final configFile = File('${assets.path}${sep}config_generated.json');

  writeJson(configFile, config);

  genNfts(configFile, layersDir, genImagesDir, genMetaDir);
}

Map<String, dynamic> genConfig(Directory layersDir, [double factor = 3]) {
  int? maxNfts;
  final configEntries = [];

  layersDir.listSync().forEach((fse) {
    if (fse is Directory) {
      final layerName = basename(fse.path);

      final Map<String, dynamic> configEntry = {};
      final Map<String, int> weights = {};

      configEntry.addAll({
        "name": layerName,
        "directory": layerName,
        "required": true,
        "weights": weights
      });
      configEntries.add(configEntry);

      final entries = Directory(fse.path).listSync();
      // for (var file in entries) {
      for (var i = 1; i <= entries.length; i++) {
        // print('  ' + basename(file.path));
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

  final Map<String, dynamic> config = {};
  config.addAll({
    "maxNftspossible": maxNfts!,
    "maxNfts": maxNfts!,
    "layers": configEntries
  });

  return config;
}

int _weight(int item, double factor) {
  if (item == 0) {
    throw 'Item is 0, must be > 1';
  }
  return pow(item, factor).round();
}

void writeJson(File configFileJson, Map<String, dynamic> config) {
  JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyprint = encoder.convert(config);
  configFileJson.writeAsStringSync(prettyprint);
}

// -----------------------------------------------------------------

String getFirstLayerPath(Directory layersDir) {
  return Directory(layersDir.listSync()[0].path).listSync()[0].path;
}

void genNfts(File configFile, Directory layersDir, Directory genImagesDir,
    Directory genMetaDir) async {
  final rnd = Random.secure();
  final input = configFile.readAsStringSync();
  final map = jsonDecode(input);
  final layers = map['layers'];
  final maxNfts = map['maxNfts'].toInt();
  // final Map<String, dynamic> generated = {};

  final forSize = await ig.decodePngFile(getFirstLayerPath(layersDir));
  var nftWidth = forSize!.width;
  var nftHeight = forSize.height;

  print("Size of layers ${forSize.width} x ${forSize.height}");

  genImagesDir.deleteSync(recursive: true);
  genMetaDir.deleteSync(recursive: true);
  genImagesDir.createSync(recursive: true);
  genMetaDir.createSync(recursive: true);

  final Set<String> dnas = {};
  final Map<int, Map<String, dynamic>> generated = {};

  // for (var nftId = 1; nftId <= maxNfts; nftId++) {
  for (var nftId = 1; nftId <= maxNfts; nftId++) {
    // print('NFTID: ${nftId.toString()}');
    String nftDna = '';
    final List<Map<String, String>> attributes = [];
    final canvas = ig.Image(width: nftWidth, height: nftHeight);

    while (nftDna.isEmpty) {
      canvas.clear();
      attributes.clear();
      nftDna = '';

      // print('LAYERS: ${layers.length}');

      for (var layer in layers) {
        final layerName = layer['name'] as String;
        final layerDir = Directory(layer['directory'] as String);
        final layerRequired = layer['required'] as bool;
        final Map<String, int> layerWeights = Map.from(layer['weights']);

        final weightsSorted = layerWeights.entries.toList();
        weightsSorted.sort(((a, b) => a.value.compareTo(b.value)));
        final int maxWeights =
            layerWeights.values.reduce((sum, value) => value + sum + value);

        // print(name);
        // print(dir);
        // print(required);
        // print(weights);
        // print(weightsSorted);

        final rndValue = rnd.nextInt(maxWeights) + 1;
        var lastValue = 1;
        for (var layerItem = 1;
            layerItem <= weightsSorted.length;
            layerItem++) {
          final currValue = weightsSorted[layerItem - 1].value;
          if (currValue > rndValue) {
            break;
          }
          lastValue = currValue;
        }

        final layerFile = weightsSorted
            .firstWhere((element) => element.value == lastValue)
            .key;
        final layerValue = layerFile.split('.')[0];

        attributes.add({"trait_type": layerName, "value": layerValue});

        final imageFile = File(layersDir.path +
            Platform.pathSeparator +
            layerDir.path +
            Platform.pathSeparator +
            layerFile);

        // print('< ${imageFile.path}');

        final bytes = await ig.decodeImageFile(imageFile.path);
        ig.compositeImage(canvas, bytes!);

        // generated[nftId]!['attributes'].add(name);
      }

      // nftDna = nftDna.md
      // nftDna = md5.convert(utf8.encode(nftDna)).toString();

      nftDna = md5
          .convert(utf8.encode(attributes
                  .map<String>(
                      (e) => e.values.reduce((sum, value) => sum + value))
                  .join('') +
              attributes
                  .map<String>(
                      (e) => e.keys.reduce((sum, value) => sum + value))
                  .join('')))
          .toString();

      if (dnas.contains(nftDna)) {
        print('EXISTS: $nftDna');
        nftDna = '';
      }
    }

    dnas.add(nftDna);

    generated.addAll({
      nftId: {
        "name": "$nftId",
        "description": "",
        "image": "ipfs://<-- Your CID Code-->/$nftId.png",
        "dna": nftDna,
        "attributes": attributes
      }
    });

    var fileImage = '${genImagesDir.path}${Platform.pathSeparator}$nftId.png';
    print('> $fileImage $nftDna');
    File(fileImage).writeAsBytesSync(ig.encodePng(canvas));

    var fileMeta = '${genMetaDir.path}${Platform.pathSeparator}$nftId.json';
    print('> $fileMeta $nftDna');
    writeJson(File(fileMeta), generated[nftId]!);
  }
}
