class Eta {
  DateTime _s0 = DateTime.now();
  void start() => _s0 = DateTime.now();
  void write(int index, int max, String message) {
    final durationPast = DateTime.now().difference(_s0);
    final durationPastStr =
        durationPast.toString().replaceAll('-', '').split('.')[0];

    final durationTotal =
        Duration(seconds: ((durationPast.inSeconds / index) * max).toInt());

    // final durationTotalStr =
    //     durationTotal.toString().replaceAll('-', '').split('.')[0];

    final durationEta = durationTotal - durationPast;
    final durationEtaStr =
        durationEta.toString().replaceAll('-', '').split('.')[0];

    print(
        '> ${index.toString().padLeft(4, " ")} / $max $message SINCE: $durationPastStr ETA: $durationEtaStr');
  }
}
