// import 'dart:async';

// import 'package:nftgen/core/helper/nftcliexception.dart';
// import 'package:nftgen/core/helper/stoptype.dart';

// /// Class to receive stop signals.
// class Stopper {
//   static final Map<StopCommand, Stopper> _stoppers = {};

//   static final String _stopWord = "stop";
//   final StreamController<String> _stop = StreamController<String>.broadcast();
//   StreamSubscription<String>? _sub;

//   /// Whether a stop signal has been sent.
//   bool isStopped = false;

//   Stopper() {
//     isStopped = false;
//     cancelSubstription();
//     _sub = _stop.stream.listen((String word) {
//       if (word == _stopWord) {
//         isStopped = true;
//         cancelSubstription();
//       }
//     });
//   }

//   void cancelSubstription() => _sub?.cancel();

//   /// Get stopper for specific command.
//   static Stopper stopper(StopCommand command) {
//     if (_stoppers.containsKey(command) == false) {
//       _stoppers.putIfAbsent(command, () => Stopper());
//     }
//     return _stoppers[command]!;
//   }

//   static void assertNotStopped(StopCommand command) {
//     if (stopper(command).isStopped == true) {
//       stopper(command).cancelSubstription();
//       // _stoppers.remove(command);
//       _stoppers.clear();
//       throw NftCliException('Aborting, received stop signal.');
//     }
//   }

//   /// Stops a given command.
//   static void stop(StopCommand command) {
//     stopper(command)._stop.sink.add(_stopWord);
//   }
// }

import 'dart:async';

import 'package:nftgen/core/helper/nftcliexception.dart';
import 'package:nftgen/core/helper/stoptype.dart';

/// Class to receive stop signals.
class Stopper {
  // static final Map<StopCommand, Stopper> _stoppers = {};

  // static final String _stopWord = "stop";
  // final StreamController<String> _stop = StreamController<String>.broadcast();
  // StreamSubscription<String>? _sub;

  /// Whether a stop signal has been sent.
  static bool _isStopped = false;

  Stopper() {
    _isStopped = false;
    // cancelSubstription();
    // _sub = _stop.stream.listen((String word) {
    //   if (word == _stopWord) {
    //     isStopped = true;
    //     cancelSubstription();
    //   }
    // });
  }

  // void cancelSubstription() => _sub?.cancel();

  /// Get stopper for specific command.
  // static Stopper stopper(StopCommand command) {
  //   if (_stoppers.containsKey(command) == false) {
  //     _stoppers.putIfAbsent(command, () => Stopper());
  //   }
  //   return _stoppers[command]!;
  // }

  static void assertNotStopped() {
    if (_isStopped) {
      throw throw NftCliException('Aborting, received stop signal.');
    }
  }

  /// Stops a given command.
  static void stop() {
    // stopper(command)._stop.sink.add(_stopWord);
    _isStopped = true;
  }
}
