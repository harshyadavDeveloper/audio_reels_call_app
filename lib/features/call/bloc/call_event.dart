abstract class CallEvent {}

class IncomingCall extends CallEvent {
  final String callerName;

  IncomingCall(this.callerName);
}

class AcceptCall extends CallEvent {}

class DeclineCall extends CallEvent {}

class EndCall extends CallEvent {}
