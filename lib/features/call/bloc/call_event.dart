abstract class CallEvent {}

class IncomingCall extends CallEvent {
  final String callerName;
  final String channelId; // ✅ Add this

  IncomingCall(this.callerName, this.channelId);
}

class AcceptCall extends CallEvent {}

class DeclineCall extends CallEvent {}

class EndCall extends CallEvent {}
