import 'dart:convert';
import 'dart:io';

class Io {
  static void writeJson(File json, Map<String, dynamic> config) {
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(config);
    json.writeAsStringSync(prettyprint);
  }

  static Map<String, dynamic> readJson(File json) {
    final input = json.readAsStringSync();
    return jsonDecode(input);
  }

  /// Saves `sortedEntries` to `csvFile`.
  static void save(List<MapEntry<String, double>> sortedEntries, File csvFile) {
    var outCsv = '';

    for (var entry in sortedEntries) {
      final String key = entry.key;
      final double count = entry.value;
      // final String perc = attributeCountPercentage[entry.key]!.toStringAsFixed(2);
      outCsv += '$key, $count\n';
    }

    csvFile.writeAsStringSync(outCsv);
  }

  static List<FileSystemEntity> getJsonFiles(Directory jsonDir) {
    return jsonDir
        .listSync()
        .where(
            (m) => m.path.endsWith('.json') && m.path.startsWith('_') == false)
        .toList();
  }
}
