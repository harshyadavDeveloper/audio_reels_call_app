import 'dart:async';

enum CallNotificationAction {
  accept,
  decline,
}

class CallActionStream {
  static final _controller =
      StreamController<CallNotificationAction>.broadcast();

  static Stream<CallNotificationAction> get stream =>
      _controller.stream;

  static void emit(CallNotificationAction action) {
    _controller.add(action);
  }
}
