import 'dart:convert';

import 'package:crypto/crypto.dart';

class Dna {
  final Set<String> _dnas = {};

  bool hasDna(String dna) => _dnas.contains(dna);

  void addDna(String dna) => _dnas.add(dna);

  /// Returns DNA based on md5 ( list.toString() )
  String getDna(List<Map<String, String>> list) {
    return md5.convert(utf8.encode(list.toString())).toString();
  }
}
