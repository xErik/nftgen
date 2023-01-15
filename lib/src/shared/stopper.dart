import 'dart:async';

import 'package:nftgen/public/nftcliexception.dart';
import 'package:nftgen/public/stoptype.dart';

/// Class to receive stop signals.
class Stopper {
  static final Map<StopCommand, Stopper> _stoppers = {};

  static final String _stopWord = "stop";
  final StreamController<String> _stop = StreamController<String>.broadcast();
  StreamSubscription<String>? _sub;

  /// Whether a stop signal has been sent.
  bool isStopped = false;

  Stopper() {
    isStopped = false;
    cancelSubstription();
    _sub = _stop.stream.listen((String word) {
      if (word == _stopWord) {
        isStopped = true;
        cancelSubstription();
      }
    });
  }

  void cancelSubstription() => _sub?.cancel();

  /// Get stopper for specific command.
  static Stopper stopper(StopCommand command) {
    if (_stoppers.containsKey(command) == false) {
      _stoppers.putIfAbsent(command, () => Stopper());
    }
    return _stoppers[command]!;
  }

  static void assertNotStopped(StopCommand command) {
    if (stopper(command).isStopped == true) {
      stopper(command).cancelSubstription();
      _stoppers.remove(command);
      throw NftCliException('Aborting, received stop signal.');
    }
  }

  /// Stops a given command.
  static void stop(StopCommand command) {
    stopper(command)._stop.sink.add(_stopWord);
  }
}