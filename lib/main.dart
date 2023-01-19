// import 'package:commandline_or_gui_windows/commandline_or_gui_windows.dart';
// import 'package:flutter/material.dart';
// import 'package:nftgen/core/helper/nftcliexception.dart';
// import 'package:nftgen/core/helper/streamprint.dart';
// import 'dart:io';

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
// Future<dynamic> main(List<String> args) async {
//   try {
//     await cli.main(args);
//   } on NftCliException catch (e) {
//     print(e.message);
//     print(e.runtimeType);
//     StreamPrint.prn(e.message);
//   } catch (e) {
//     print(e);
//     StreamPrint.prn(e.toString());
//   }
// }

import 'dart:io';

import 'package:commandline_or_gui_windows/commandline_or_gui_windows.dart';
import 'package:flutter/material.dart';
import 'package:nftgen/cli.dart' as cli;

main(List<String> args) {
  CommandlineOrGuiWindows.runAppCommandlineOrGUI(
      argsCount: args.length,
      closeOnCompleteCommandlineOptionOnly: true,
      commandlineRun: () async {
        // print(args);
        // stdout.writeln(args);
        await cli.main(args);
        exit(0);
      },
      gui: const MaterialApp(
          home: Scaffold(
              body: Center(
                  child: Text("Run this EXE with arguments!",
                      style: TextStyle(fontWeight: FontWeight.w900))))));
}
