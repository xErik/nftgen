import 'dart:io';
import 'dart:math';

import 'package:nftgen/src/shared/stopper.dart';
import 'package:nftgen/src/shared/eta.dart';
import 'package:nftgen/src/shared/io.dart';

import 'package:image/image.dart' as ig;

/// Calculates rarity based on metadata for NFT and
/// individual layers.
class Rarity {
  /// Takes a directory with JSON metadata files and returns a
  /// list of `MapEntries` sorted by value / rarity.
  ///
  /// The value is the percentage of NFTs an attribute appears in.
  /// A low value indicates high rarity of an attribute.
  static List<MapEntry<String, double>> layers(Directory metaDir) {
    final Map<String, int> attributeCountAbsolute = {};
    final Map<String, double> attributeCountPercentage = {};
    final metasFiles = Io.getJsonFiles(metaDir);

    for (var meta in metasFiles) {
      Stopper.assertNotStopped();
      final metaJson = Io.readJson(File(meta.path));
      final List<dynamic> atts = metaJson['attributes'];

      for (var att in atts) {
        final key = att['trait_type'];
        final val = att['value'];
        if (key == null || val == null) {
          continue;
        }
        final String keyVal = key + '-' + val.toString();
        attributeCountAbsolute.putIfAbsent(keyVal, () => 0);
        attributeCountAbsolute[keyVal] = attributeCountAbsolute[keyVal]! + 1;
      }
    }

    for (var entry in attributeCountAbsolute.entries) {
      attributeCountPercentage.putIfAbsent(entry.key, () => 0);
      attributeCountPercentage[entry.key] = double.parse(
          ((100 / metasFiles.length) * entry.value).toStringAsFixed(4));
    }

    final sortedEntries = attributeCountPercentage.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries;
  }

  /// Takes a directory with JSON metadata files and returns a
  /// list of MapEntries sorted by value, expressing the rarity.
  ///
  /// High value indicates high rarity.
  ///
  /// Formula:
  ///
  /// [Rarity Score for a Trait Value] = 1 / ([Number of Items with that Trait Value] / [Total Number of Items in Collection])
  /// The total Rarity Score for an NFT is the sum of the Rarity Score of all of it’s trait values.
  static List<MapEntry<String, double>> nfts(Directory metaDir) {
    final eta = Eta()..start();
    final Map<String, int> attributeCountAbsolute = {};
    final Map<String, double> attributeCountPercentage = {};
    final metas = Io.getJsonFiles(metaDir);

    for (var i = 0; i < metas.length; i++) {
      Stopper.assertNotStopped();

      final meta = metas.elementAt(i);
      final js = Io.readJson(File(meta.path));
      final List<dynamic> atts = js['attributes'];

      for (var att in atts) {
        final key = att['trait_type'];
        final val = att['value'];
        if (key == null || val == null) {
          continue;
        }
        final String keyVal = key + '-' + val.toString();
        attributeCountAbsolute.putIfAbsent(keyVal, () => 0);
        attributeCountAbsolute[keyVal] = attributeCountAbsolute[keyVal]! + 1;
      }
      eta.write(i + 1, metas.length * 2, '');
    }

    for (var entry in attributeCountAbsolute.entries) {
      attributeCountPercentage.putIfAbsent(entry.key, () => 0);
      attributeCountPercentage[entry.key] = (100 / metas.length) * entry.value;
    }

    final Map<String, double> items = {};

    for (var i = 0; i < metas.length; i++) {
      Stopper.assertNotStopped();

      final meta = metas.elementAt(i);
      final js = Io.readJson(File(meta.path));
      final List<dynamic> atts = js['attributes'];

      var rarity = 0.0;

      // [Rarity Score for a Trait Value] = 1 / ([Number of Items with that Trait Value] / [Total Number of Items in Collection])
      // The total Rarity Score for an NFT is the sum of the Rarity Score of all of it’s trait values.

      for (var att in atts) {
        final key = att['trait_type'];
        final val = att['value'];
        if (key == null || val == null) {
          continue;
        }
        final String keyVal = key + '-' + val.toString();
        final itemCount = attributeCountAbsolute[keyVal]!;

        rarity += 1 / (itemCount / metas.length);
      }

      items[meta.path] = rarity;

      eta.write(i + 1, metas.length * 2, '');
    }

    final sortedEntries = items.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries;
  }

  /// Draws a small line chart, displaying the `entries` and saves it locally.
  static Future drawChart(String imgFile,
      List<MapEntry<String, double>> entries, String label) async {
    final width = entries.length;
    final height = entries.last.value.toInt();

    final red = ig.ColorRgb8(255, 0, 0);
    final black = ig.ColorRgb8(0, 0, 0);
    final white = ig.ColorRgb8(255, 255, 255);

    final cmd = ig.Command()
      ..createImage(width: width, height: height)
      ..fill(color: white);

    int x0 = 0;
    int y0 = 0;
    for (var x = 0; x < entries.length; x++) {
      final y = entries[x].value.round();

      cmd.drawLine(x1: x0, y1: y0, x2: x, y2: y, color: red);
      x0 = x;
      y0 = y;
    }

    final int wNew;
    final double factor;
    final int hNew;

    if (width >= height) {
      wNew = max(300, width);
      factor = (1 / width) * wNew;
      hNew = (height * factor).toInt();
    } else {
      hNew = max(300, height);
      factor = (1 / height) * hNew;
      wNew = (width * factor).toInt();
    }

    cmd
      ..copyResize(width: wNew, height: hNew)
      ..flip(direction: ig.FlipDirection.horizontal);
    if (height > width) {
      cmd.copyRotate(angle: 90);
      cmd.drawString(label, font: ig.arial14, x: 0, y: wNew - 14, color: black);
      cmd.copyRotate(angle: -90);
    } else {
      cmd.drawString(label, font: ig.arial24, x: 0, y: 0, color: black);
    }

    cmd.writeToFile(imgFile);
    await cmd.execute();
  }
}
