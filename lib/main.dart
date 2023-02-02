import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:nftgen/framework/drawbase.dart';
import 'package:nftgen/framework/nftcliexception.dart';
import 'package:nftgen/src/cmd/cmdcrunch.dart';
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
Future<dynamic> nft(String projectDir,
        {int size = -1, DrawBase? drawServiceBase}) async =>
    await main(["nft", "-f", projectDir, '-s', size.toString(), "--no-kill"],
        drawServiceBase);

/// Runs NFT image generation based on metadata
Future<dynamic> demo(String projectDir, String layerDir, String name,
        {int size = -1, DrawBase? drawServiceBase}) async =>
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
    ], drawServiceBase);

/// Runs NFT image generation based on metadata
Future<dynamic> crunch(String projectDir,
    {int quality = 11, bool overwrite = false}) async {
  final or = (overwrite == true) ? "--overwrite" : "--no-overwrite";

  await main([
    "crunch",
    "-f",
    projectDir,
    '-q',
    quality.toString(),
    '-o',
    or,
    "--no-kill"
  ]);
}

/// Stops the specific command.
void stop() => Stopper.stop();

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
Future<dynamic> main(List<String> args, [DrawBase? drawService]) async {
  final runner = CommandRunner("nftgen", "Generate NFTs")
    ..addCommand(DemoCommand(drawService))
    ..addCommand(InitCommand())
    ..addCommand(MetaCommand())
    ..addCommand(RarityCommand())
    ..addCommand(CidCommand())
    ..addCommand(CrunchCommand())
    ..addCommand(NftCommand(drawService));
  try {
    await runner.run(args);
    if (args.contains("--no-kill") == false) {
      exit(0);
    }
  } catch (error, stack) {
    // stderr.writeln(error);
    // stderr.writeln(stack);

    if (error is NftException) {
      stderr.writeln(error.message);
    } else {
      stderr.writeln(error);
      stderr.writeln(stack);
    }
    // EXIT if on pure CLI
    if (args.contains("--no-kill") == false) {
      exit(64); // Exit code 64 indicates a usage error.
    }
    if (error is! UsageException) {
      rethrow;
    }
  }
}
