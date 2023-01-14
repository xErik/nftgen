import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/public/stoptype.dart';
import 'package:nftgen/src/shared/stopper.dart';

import 'src/cmd/cmdcid.dart';
import 'src/cmd/cmdinit.dart';
import 'src/cmd/cmdmeta.dart';
import 'src/cmd/cmdnft.dart';
import 'src/cmd/cmdrarity.dart';

/// Runs INIT
Future<dynamic> init(
    String projectDir, String layerDir, String name, bool overwrite) async {
  final or = (overwrite == true) ? "--overwrite" : "--no-overwrite";
  await main(
      ["init", "-p", projectDir, "-l", layerDir, "-n", name, or, "--no-kill"]);
}

/// Runs META generation
Future<dynamic> meta(String projectDir) async =>
    await main(["meta", "-p", projectDir, "--no-kill"]);

/// Runs RARITY based on metadata
Future<dynamic> rarity(String projectDir) async =>
    await main(["rarity", "-p", projectDir, "--no-kill"]);

/// Runs CID update on metadata
Future<dynamic> cid(String projectDir, String cid) async =>
    await main(["cid", "-p", projectDir, "-c", cid, "--no-kill"]);

/// Runs NFT image generation based on metadata
Future<dynamic> nft(String projectDir) async =>
    await main(["nft", "-p", projectDir, "--no-kill"]);

void stop(StopCommand command) => Stopper.stop(command);

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args) async {
  final runner = CommandRunner("nftgen", "Generate NFTs")
    ..addCommand(InitCommand())
    ..addCommand(MetaCommand())
    ..addCommand(RarityCommand())
    ..addCommand(CidCommand())
    ..addCommand(NftCommand());
  try {
    await runner.run(args);
  } catch (error) {
    print(error);
    // print(error.message);
    // EXIT if on pure CLI
    if (args.contains("--no-kill") == false) {
      print("Exiting.");
      exit(64); // Exit code 64 indicates a usage error.
    }
    // This will throw CliException in case am expected
    // DIR is not found etc.
    // ignore: use_rethrow_when_possible
    if (error is! UsageException) throw error;
  }
}
