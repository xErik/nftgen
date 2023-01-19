import 'package:duration/duration.dart';
import 'package:nftgen/core/helper/streamprint.dart';

class Eta {
  DateTime _s0 = DateTime.now();
  DateTime _s0Last = DateTime.now();
  final List<int> _durationsEta = [];

  void start() {
    _s0 = DateTime.now();
    _s0Last = DateTime.now();
  }

  void write(int index, int max, String message) {
    final durationPast = DateTime.now().difference(_s0);
    final durationPastStr = prettyDuration(durationPast, abbreviated: true);

    final durationTotal =
        Duration(seconds: ((durationPast.inSeconds / index) * max).toInt());

    var durationEta = durationTotal - durationPast;
    _durationsEta.add(durationEta.inSeconds);
    durationEta = Duration(
        seconds: _durationsEta.reduce((sum, element) => sum + element) ~/
            _durationsEta.length);
    if (_durationsEta.length > 5) {
      _durationsEta.removeAt(0);
    }

    final durationEtaStr = prettyDuration(durationEta, abbreviated: true);

    final durationLast = DateTime.now().difference(_s0Last);
    final durationLastStr = prettyDuration(
      durationLast,
      abbreviated: true,
      tersity: DurationTersity.millisecond,
    );

    _s0Last = DateTime.now();

    final out =
        '${index.toString().padLeft(4, " ")} / $max $message TOOK: $durationLastStr SINCE: $durationPastStr ETA: $durationEtaStr';

    StreamPrint.prn(out);
  }
}
