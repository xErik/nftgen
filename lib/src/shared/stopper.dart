import 'package:nftgen/framework/nftcliexception.dart';

/// Class to receive stop signals.
class Stopper {
  /// Whether a stop signal has been sent.
  static bool _isStopped = false;

  Stopper() {
    _isStopped = false;
  }

  /// Whether to stop, queried by commands.
  static void assertNotStopped() {
    if (_isStopped) {
      _isStopped = false;
      throw throw NftStopException('Exiting, received stop signal.');
    }
  }

  /// Stops a given command.
  static void stop() {
    _isStopped = true;
  }
}
