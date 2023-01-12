import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/streamprint.dart';

import 'cmd/cmdcid.dart';
import 'cmd/cmdinit.dart';
import 'cmd/cmdmeta.dart';
import 'cmd/cmdnft.dart';
import 'cmd/cmdrarity.dart';

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
void main(List<String> args) {
  CommandRunner("nftgen", "Generate NFTs")
    ..addCommand(InitCommand())
    ..addCommand(MetaCommand())
    ..addCommand(RarityCommand())
    ..addCommand(CidCommand())
    ..addCommand(NftCommand())
    // ..addCommand(HelpCommand())
    ..run(args).catchError((error) {
      if (error is! UsageException) throw error;
      StreamPrint.prn(error.toString());
      exit(64); // Exit code 64 indicates a usage error.
    });
}
