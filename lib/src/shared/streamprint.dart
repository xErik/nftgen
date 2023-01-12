import 'dart:async';

class StreamPrint {
  static final StreamController _controller =
      StreamController<String>.broadcast();

  static Stream get stream => _controller.stream;

  static void prn(String str) {
    _controller.add(str);
    print(str);
  }
}
