import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifService {
  static final LocalNotifService _i = LocalNotifService._();
  LocalNotifService._();
  factory LocalNotifService() => _i;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    const channel = AndroidNotificationChannel(
      'bus_updates',
      'Bus Updates',
      description: 'Check-in/out updates for your children',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> show(
      {required int id, required String title, required String body}) async {
    const android = AndroidNotificationDetails('bus_updates', 'Bus Updates',
        priority: Priority.high, importance: Importance.high);
    const ios = DarwinNotificationDetails();
    await _plugin.show(
        id, title, body, const NotificationDetails(android: android, iOS: ios));
  }
}
