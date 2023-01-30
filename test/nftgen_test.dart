@Timeout(Duration(minutes: 5))

import 'dart:io';

import 'package:nftgen/main.dart' as cli;
import 'package:nftgen/framework/nftcliexception.dart';

import 'package:test/test.dart';

void main() {
  test('generateConfigAndNftFromLayers', () async {
    try {
      final sep = Platform.pathSeparator;
      final String projectDir = 'project';
      final String layerDir = '$projectDir${sep}layer';
      final String name = "NFT Test name";

      await cli.init(projectDir, layerDir, name, true);
      await cli.meta(projectDir);
      await cli.rarity(projectDir);
      await cli.cid(projectDir, "NEW-CID");
      await cli.crunch(projectDir, overwrite: true);
      await cli.nft(projectDir);
    } on NftException catch (e) {
      print(e.message);
    }
  });
}
