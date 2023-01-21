import 'dart:io';

import 'package:nftgen/main.dart' as cli;
import 'package:nftgen/framework/nftcliexception.dart';

/// Entry point for Dart command line usage.
///
/// Invokes `lib/cli.dart`
///
/// `dart run bin/nftgen.dart <COMMAND> ...`
///
/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args) async {
  try {
    await cli.main(args);
  } on NftException catch (e) {
    stderr.writeln(e.message);
  }
}
