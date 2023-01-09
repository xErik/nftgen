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
}
