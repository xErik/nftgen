import 'dart:io';

import 'package:io/io.dart';

void main(List<String> args) async {
  final sep = Platform.pathSeparator;
  // stdout.writeln('Building wrapper for main app...');
  // await Process.run('dart', ['compile', 'exe', '.${sep}bin${sep}nftgen.dart'],
  //         runInShell: true)
  //     .then((ProcessResult pr) {
  //   // print(pr.exitCode);
  //   // print(pr.stdout);
  //   print(pr.stderr);
  // });

  stdout.writeln('Building main app ...');
  await Process.run('flutter', ['build', 'windows'], runInShell: true)
      .then((ProcessResult pr) {
    // print(pr.exitCode);
    // print(pr.stdout);
    print(pr.stderr);
  });

  stdout.writeln('Copying main app to bin...');
  final to = Directory('.${sep}bin${sep}');
  to.createSync(recursive: true);
  copyPathSync(
      '.${sep}build${sep}windows${sep}runner${sep}Release${sep}', to.path);

  final exeOld = File('${to.path}${sep}com_nft_generate.exe');
  final exeNew = File('${to.path}${sep}nftgen.exe');
  exeNew.writeAsBytesSync(exeOld.readAsBytesSync());
  exeOld.deleteSync();
}
