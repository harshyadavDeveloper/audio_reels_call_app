enum CallStatus {
  idle,
  incoming,
  accepted,
  declined,
  ended,
}

class CallModel {
  final String callId;
  final String callerName;
  final CallStatus status;

  CallModel({
    required this.callId,
    required this.callerName,
    required this.status,
  });

  CallModel copyWith({
    CallStatus? status,
  }) {
    return CallModel(
      callId: callId,
      callerName: callerName,
      status: status ?? this.status,
    );
  }
}
