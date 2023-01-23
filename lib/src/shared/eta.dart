import 'package:duration/duration.dart';
import 'package:nftgen/framework/streamprint.dart';

class Eta {
  late final DateTime _s0;
  DateTime _s0Last = DateTime.now();
  final List<int> _durationsEta = [];

  void start() {
    _s0 = DateTime.now();
    _s0Last = DateTime.now();
  }

  void write(int index, int max, String message) {
    if (index == 0) {
      throw 'index is not allowed to be 0, start with 1';
    }

    if (message.length > 30) {
      message = '...${message.substring(message.length - 30)}';
    }

    final sinceDatetime = DateTime.now().difference(_s0);
    final sinceStr = prettyDuration(sinceDatetime, abbreviated: true);

    // -----------------------------------------------------------
    // TOTAL
    // -----------------------------------------------------------

    final totalDuration =
        Duration(seconds: ((sinceDatetime.inSeconds / index) * max).toInt());

    // -----------------------------------------------------------
    // ETA
    // -----------------------------------------------------------

    var durationEta = totalDuration - sinceDatetime;
    _durationsEta.add(durationEta.inSeconds);

    durationEta = Duration(
        seconds: _durationsEta.reduce((sum, element) => sum + element) ~/
            _durationsEta.length);
    if (_durationsEta.length > 5) {
      _durationsEta.removeAt(0);
    }
    final etaStr = prettyDuration(durationEta, abbreviated: true);

    // -----------------------------------------------------------
    // TOOK
    // -----------------------------------------------------------

    final tookDuration = DateTime.now().difference(_s0Last);
    final tookStr = prettyDuration(
      tookDuration,
      abbreviated: true,
      tersity: DurationTersity.second,
    );

    // -----------------------------------------------------------
    // WRITE
    // -----------------------------------------------------------

    _s0Last = DateTime.now();

    final idxStr = index.toString().padLeft(4, " ");

    final out =
        '$idxStr / $max $message TOOK: $tookStr SINCE: $sinceStr ETA: $etaStr';

    StreamPrint.prn(out);
  }
}
