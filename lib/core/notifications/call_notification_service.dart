import 'package:audio_call_task/core/notifications/call_action_stream.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CallNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'incoming_call_channel';
  static const String _channelName = 'Incoming Calls';

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationAction,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Incoming call notifications',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showIncomingCall({
    required String callerName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      category: AndroidNotificationCategory.call,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: [
        AndroidNotificationAction(
          'ACCEPT_CALL',
          'Accept',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'DECLINE_CALL',
          'Decline',
          cancelNotification: true,
        ),
      ],
    );

    await _notifications.show(
      1001,
      'Incoming Call',
      '$callerName is calling',
      const NotificationDetails(android: androidDetails),
    );
  }

 static void _onNotificationAction(
  NotificationResponse response,
) {
  switch (response.actionId) {
    case 'ACCEPT_CALL':
      CallActionStream.emit(CallNotificationAction.accept);
      break;

    case 'DECLINE_CALL':
      CallActionStream.emit(CallNotificationAction.decline);
      break;
  }
}

}
