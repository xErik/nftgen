import 'dart:async';
import 'dart:io';

enum PrintType { ok, warn, error, progress }

/// Class renders messages: ok, wanr, error
class PrintContent {
  PrintType type;
  String str;
  PrintContent(this.str, [this.type = PrintType.ok]);

  @override
  String toString() {
    final prefix = type == PrintType.ok
        ? "✅"
        : type == PrintType.warn
            ? "⚠"
            : type == PrintType.progress
                ? "📀"
                : "❌";

    return "$prefix $str";
  }
}

/// Recives and broadcastes messages.
class StreamPrint {
  static final StreamController<PrintContent> _controller =
      StreamController<PrintContent>.broadcast();

  /// Returns a message Stream.
  static Stream<PrintContent> get stream => _controller.stream;

  /// Adds an OK message.
  static void prn(String str) {
    _controller.add(PrintContent(str));
    stdout.writeln(str);
  }

  /// Adds an error message.
  static void err(String str) {
    _controller.add(PrintContent(str, PrintType.error));
    // print(str);
    stderr.writeln(str);
  }

  /// Adds a warning message.
  static void warn(String str) {
    _controller.add(PrintContent(str, PrintType.warn));
    // print(str);
    stdout.writeln(str);
  }
}
