import 'dart:async';

enum Type { ok, warn, error }

class PrintContent {
  Type type;
  String str;
  PrintContent(this.str, [this.type = Type.ok]);
}

class StreamPrint {
  static final StreamController<PrintContent> _controller =
      StreamController<PrintContent>.broadcast();

  static Stream<PrintContent> get stream => _controller.stream;

  static void prn(String str) {
    _controller.add(PrintContent(str));
    print(str);
  }

  static void err(String str) {
    _controller.add(PrintContent(str, Type.error));
    print(str);
  }

  static void warn(String str) {
    _controller.add(PrintContent(str, Type.warn));
    print(str);
  }
}
