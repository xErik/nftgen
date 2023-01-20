import 'dart:io';

import 'package:commandline_or_gui_windows/commandline_or_gui_windows.dart';
import 'package:flutter/material.dart';
import 'package:nftgen/framework/drawflutter.dart';
import 'package:nftgen/main.dart' as cli;

/// Calls `lib/interface.dart` with NFT drawing using `Flutter Canvas`.
///
/// Entry point for building Flutter command line EXE in `bin/nftgen.exe`
/// by using `dart build tool/build.dart`.
///
/// Entry point for development, define parameters as:
/// `flutter run lib/main_flutter.dart -d windows --dart-entrypoint-args init,-f,.\project\,-l,.\project\layer\,-o,-n,test`
///
/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<void> main(List<String> args) async {
  CommandlineOrGuiWindows.runAppCommandlineOrGUI(
    argsCount: args.length,
    closeOnCompleteCommandlineOptionOnly: true,
    commandlineRun: () async {
      await cli.main(args, DrawFlutter());
      exit(0);
    },
    gui: const MaterialApp(
        home: Scaffold(
            body: Center(
                child: Text("Run this EXE with arguments!",
                    style: TextStyle(fontWeight: FontWeight.w900))))),
  );
}
