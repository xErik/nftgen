@Timeout(Duration(minutes: 5))

import 'dart:io';

import 'package:nftgen/cli.dart' as cli;

import 'package:test/test.dart';

void main() {
  test('generateConfigAndNftFromLayers', () {
    final sep = Platform.pathSeparator;
    final String projectDir = 'project';
    final String layerDir = '$projectDir${sep}layer';
    final String name = "NFT Test name";

    cli.init(projectDir, layerDir, name, true);

    cli.meta(projectDir);

    cli.rarity(projectDir);

    cli.cid(projectDir, "NEW-CID");

    // IMAGE does work from within tests?
    // cli.nft(projectDir);
  });
}
