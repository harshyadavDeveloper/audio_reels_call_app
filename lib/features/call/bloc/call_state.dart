import '../data/call_model.dart';

abstract class CallState {}

class CallIdle extends CallState {}

class CallInProgress extends CallState {
  final CallModel call;

  CallInProgress(this.call);
}
