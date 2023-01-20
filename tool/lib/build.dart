import 'dart:io';

import 'package:io/io.dart';

void main(List<String> args) async {
  final sep = Platform.pathSeparator;

  stdout.writeln('Building release EXE ...');
  await Process.run('flutter', ['build', 'windows', 'tool/lib/exe.dart'],
          runInShell: true)
      .then((ProcessResult pr) {
    // print(pr.exitCode);
    // print(pr.stdout);
    print(pr.stderr);
  });

  stdout.writeln('Copying release EXE to bin...');
  final to = Directory('.${sep}bin$sep');
  to.createSync(recursive: true);
  copyPathSync(
      '.${sep}build${sep}windows${sep}runner${sep}Release$sep', to.path);

  final exeOld = File('${to.path}${sep}com_nft_generate.exe');
  final exeNew = File('${to.path}${sep}nftgen.exe');
  exeNew.writeAsBytesSync(exeOld.readAsBytesSync());
  exeOld.deleteSync();

  stdout.writeln('Find release EXE at: $exeNew');
}
