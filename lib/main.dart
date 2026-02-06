import 'package:audio_call_task/app/app.dart';
import 'package:audio_call_task/core/notifications/call_notification_service.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await CallNotificationService.init();
  runApp(const MyApp());
}