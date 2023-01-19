import 'package:commandline_or_gui_windows/commandline_or_gui_windows.dart';
import 'package:flutter/material.dart';
import 'package:nftgen/core/helper/nftcliexception.dart';
import 'package:nftgen/core/helper/streamprint.dart';
import 'package:nftgen/cli.dart' as cli;
import 'dart:io';

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
// Future<dynamic> main(List<String> args) async {
//   try {
//     await m.main(args);
//   } on NftCliException catch (e) {
//     print(e.message);
//     print(e.runtimeType);
//     StreamPrint.prn(e.message);
//   } catch (e) {
//     print(e);
//     StreamPrint.prn(e.toString());
//   }
// }

/// Available as a development wrapper for generating an EXE.
main(List<String> args) {
  CommandlineOrGuiWindows.runAppCommandlineOrGUI(
      argsCount: args.length,
      closeOnCompleteCommandlineOptionOnly: true,
      commandlineRun: () async {
        try {
          await cli.main(args);
          exit(0);
        } on NftCliException catch (e) {
          print(e.message);
          StreamPrint.prn(e.message);
          exit(1);
        } catch (e) {
          print(e);
          StreamPrint.prn(e.toString());
          exit(1);
        }
      },

      // gui to be shown when running in gui mode
      gui: const MaterialApp(
          home: Scaffold(
              body: Center(
                  child: Text("Run this EXE with arguments!",
                      style: TextStyle(fontWeight: FontWeight.w900))))));
}
