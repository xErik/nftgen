import 'package:nftgen/public/streamprint.dart';
import 'package:nftgen/cli.dart' as m;

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args) async {
  try {
    await m.main(args);
  } catch (error) {
    StreamPrint.prn(error.toString());
  }
}
