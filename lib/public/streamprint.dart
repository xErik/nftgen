import 'dart:async';

enum Type { ok, warn, error, progress }

/// Class renders messages: ok, wanr, error
class PrintContent {
  Type type;
  String str;
  PrintContent(this.str, [this.type = Type.ok]);

  @override
  String toString() {
    final prefix = type == Type.ok
        ? "✅"
        : type == Type.warn
            ? "⚠"
            : type == Type.progress
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
    print(str);
  }

  /// Adds an error message.
  static void err(String str) {
    _controller.add(PrintContent(str, Type.error));
  }

  /// Adds a warning message.
  static void warn(String str) {
    _controller.add(PrintContent(str, Type.warn));
    print(str);
  }
}
