import 'dart:convert';

import 'package:crypto/crypto.dart';

class Dna {
  final Set<String> _dnas = {};

  bool hasDna(String dna) => _dnas.contains(dna);

  void addDna(String dna) => _dnas.add(dna);

  String getDna(List<Map<String, String>> list) {
    return md5
        .convert(utf8.encode(list
                .map<String>(
                    (e) => e.values.reduce((sum, value) => sum + value))
                .join('') +
            list
                .map<String>((e) => e.keys.reduce((sum, value) => sum + value))
                .join('')))
        .toString();
  }
}
