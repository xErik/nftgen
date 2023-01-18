import 'package:nftgen/core/helper/nftcliexception.dart';
import 'package:nftgen/core/helper/streamprint.dart';
import 'package:nftgen/cli.dart' as m;

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args) async {
  try {
    await m.main(args);
  } on NftCliException catch (e) {
    print(e.message);
    print(e.runtimeType);
    StreamPrint.prn(e.message);
  } catch (e) {
    print(e);
    StreamPrint.prn(e.toString());
  }
}
