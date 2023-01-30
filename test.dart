import 'package:isolate_pool_2/isolate_pool_2.dart';

// ---------------------------------------------------------
// MAIN
// ---------------------------------------------------------

void main(List<String> args) async {
  final List<Future> futures = [];
  final pool = IsolatePool(2);
  await pool.start();

  try {
    for (var i = 0; i < 5; i++) {
      print('SLEEPING before adding job $i');
      await Future.delayed(Duration(seconds: 1), () => null);

      final job = MyJob(i);
      futures.add(pool.scheduleJob(job));
    }

    print('WATING for futures: ${futures.length} ');

    await Future.wait(futures, eagerError: true);
  } on MyException catch (e) {
    print('CAUGHT: ${e.message}');
  } finally {
    try {
      print('Stopping ...');
      pool.stop();
    } catch (_) {
      // ignore safety measure
    }
  }
}

// ---------------------------------------------------------
// JOB
// ---------------------------------------------------------

class MyJob extends PooledJob {
  final int i;
  MyJob(this.i);

  @override
  job() async {
    print('EXECUTING JOB: $i');
    await Future.delayed(Duration(seconds: 1));

    if (i == 0) {
      throw MyException('Thrown at: $i');
    }

    return i;
  }
}

// ---------------------------------------------------------
// EXCEPTION
// ---------------------------------------------------------

class MyException implements Exception {
  final String message;
  MyException(this.message);
}
