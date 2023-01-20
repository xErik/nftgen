import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/core/helper/nftcliexception.dart';
import 'package:nftgen/core/helper/stoptype.dart';
import 'package:nftgen/src/cmd/cmddemo.dart';
import 'package:nftgen/src/shared/stopper.dart';

import 'src/cmd/cmdcid.dart';
import 'src/cmd/cmdinit.dart';
import 'src/cmd/cmdmeta.dart';
import 'src/cmd/cmdnft.dart';
import 'src/cmd/cmdrarity.dart';

/// Runs INIT
Future<dynamic> init(
    String projectDir, String layerDir, String name, bool overwrite,
    {double w = 2.0, double p = 0.5}) async {
  final or = (overwrite == true) ? "--overwrite" : "--no-overwrite";
  await main([
    "init",
    "-f",
    projectDir,
    "-l",
    layerDir,
    "-n",
    name,
    "-w",
    w.toString(),
    "-p",
    p.toString(),
    or,
    "--no-kill"
  ]);
}

/// Runs META generation
Future<dynamic> meta(String projectDir, [int size = -1]) async =>
    await main(["meta", "-f", projectDir, "-s", size.toString(), "--no-kill"]);

/// Runs RARITY based on metadata
Future<dynamic> rarity(String projectDir) async =>
    await main(["rarity", "-f", projectDir, "--no-kill"]);

/// Runs CID update on metadata
Future<dynamic> cid(String projectDir, String cid) async =>
    await main(["cid", "-f", projectDir, "-c", cid, "--no-kill"]);

/// Runs NFT image generation based on metadata
Future<dynamic> nft(String projectDir, {int size = -1}) async =>
    await main(["nft", "-f", projectDir, '-s', size.toString(), "--no-kill"]);

/// Runs NFT image generation based on metadata
Future<dynamic> demo(String projectDir, String layerDir, String name,
        {int size = -1}) async =>
    await main([
      "demo",
      "-f",
      projectDir,
      "-l",
      layerDir,
      '-n',
      name,
      '-w',
      "0.0",
      "--no-kill",
      "-s",
      size.toString()
    ]);

/// Stops the specific command.
void stop() => Stopper.stop();

/// Available as a package for Flutter apps.
///
/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args) async {
  final runner = CommandRunner("nftgen", "Generate NFTs")
    ..addCommand(DemoCommand())
    ..addCommand(InitCommand())
    ..addCommand(MetaCommand())
    ..addCommand(RarityCommand())
    ..addCommand(CidCommand())
    ..addCommand(NftCommand());
  try {
    await runner.run(args);
  } catch (error, stack) {
    if (error is NftCliException) {
      print(error.message);
    } else {
      print(error);
      // print(stack);
    }
    // EXIT if on pure CLI
    if (args.contains("--no-kill") == false) {
      if (error is! UsageException) {
        print("Exiting.");
      }
      exit(64); // Exit code 64 indicates a usage error.
    } else {
      print(stack);
    }
    // This will throw CliException in case am expected
    // DIR is not found etc.
    // ignore: use_rethrow_when_possible
    if (error is! UsageException) {
      rethrow;
    }
  }
}
