import 'dart:io';

import 'package:args/command_runner.dart';

import 'src/cmd/cmdcid.dart';
import 'src/cmd/cmdinit.dart';
import 'src/cmd/cmdmeta.dart';
import 'src/cmd/cmdnft.dart';
import 'src/cmd/cmdrarity.dart';

/// Runs INIT
void init(String projectDir, String layerDir, String name, bool overwrite) {
  final or = (overwrite == true) ? "--overwrite" : "--no-overwrite";
  main(["init", "-p", projectDir, "-l", layerDir, "-n", name, or, "--no-kill"]);
}

/// Runs META generation
void meta(String projectDir) => main(["meta", "-p", projectDir, "--no-kill"]);

/// Runs RARITY based on metadata
void rarity(String projectDir) =>
    main(["rarity", "-p", projectDir, "--no-kill"]);

/// Runs CID update on metadata
void cid(String projectDir, String cid) =>
    main(["cid", "-p", projectDir, "-c", cid, "--no-kill"]);

/// Runs NFT image generation based on metadata
void nft(String projectDir) => main(["nft", "-p", projectDir, "--no-kill"]);

/// General command template:
/// nftgen <COMMAND> [<PROJECT-DIR>] <PARAMETERS>
///
/// Add --no-kill and method will throw `NftCliException`
/// instead of calling exit(64).
void main(List<String> args) {
  CommandRunner("nftgen", "Generate NFTs")
    ..addCommand(InitCommand())
    ..addCommand(MetaCommand())
    ..addCommand(RarityCommand())
    ..addCommand(CidCommand())
    ..addCommand(NftCommand())
    ..run(args).catchError((error) {
      print(error);
      // print(error.message);
      // EXIT if on pure CLI
      if (args.contains("--no-kill") == false) {
        print("Exiting.");
        exit(64); // Exit code 64 indicates a usage error.
      }
      // This will throw CliException in case am expected
      // DIR is not found etc.
      if (error is! UsageException) throw error;
    });
}
