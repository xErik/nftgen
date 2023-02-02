import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:io/io.dart' as cp;

void main(List<String> args) async {
  final sep = Platform.pathSeparator;

  stdout.writeln('Building ...');
  await Process.run('flutter', ['build', 'windows', 'tool/lib/exe.dart'],
          runInShell: true)
      .then((ProcessResult pr) {
    // print(pr.exitCode);
    // print(pr.stdout);
    stderr.writeln(pr.stderr);
  });

  // stdout.writeln('Copying release EXE to bin...');
  final binDir = Directory('.${sep}bin$sep');
  if (binDir.existsSync()) {
    binDir.deleteSync(recursive: true);
  }
  binDir.createSync(recursive: true);
  cp.copyPathSync(
      '.${sep}build${sep}windows${sep}runner${sep}Release$sep', binDir.path);

  final exeOld = File('${binDir.path}${sep}com_nft_generate.exe');
  final exeNew = File('${binDir.path}${sep}nftgen.exe');
  exeNew.writeAsBytesSync(exeOld.readAsBytesSync());
  exeOld.deleteSync();

  final distDir = Directory('.${sep}dist$sep');
  if (distDir.existsSync()) {
    distDir.deleteSync(recursive: true);
  }
  distDir.createSync(recursive: true);

  stdout.writeln('Pngquant ...');

  cp.copyPathSync(
      '.${sep}tool${sep}lib${sep}pngquant$sep', '${binDir.path}${sep}pngquant');

  stdout.writeln('Zipping ...');

  var encoder = ZipFileEncoder();
  encoder.zipDirectory(Directory('bin'), filename: 'dist/nftgen.zip');

  stdout.writeln('Find release ZIP at: ${distDir.path}');
}
