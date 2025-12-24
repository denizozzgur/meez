
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../notifications/notification_content.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Android Setup
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Setup
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap logic here
        if (kDebugMode) {
          print("Notification tapped: ${response.payload}");
        }
      },
    );

    _isInitialized = true;
  }
  
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Called when app goes to background / terminates
  Future<void> scheduleSmartNotifications() async {
    // 1. Cancel existing scheduled notifications to avoid duplicates/spam
    await cancelAll();

    // 2. Schedule "Reactivation" for 5 days later
    await _scheduleReactivation();

    // 3. Schedule next "Context-Aware" or "Inspiration" notification short term (tomorrow)
    await _scheduleNextInspiration();
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _scheduleReactivation() async {
    final item = NotificationContent.reactivation;
    await _zonedSchedule(
      id: item.id,
      title: item.title,
      body: item.body,
      payload: item.payload,
      scheduledDate: _nextInstance(daysOffset: 5, hour: item.hour),
    );
  }

  Future<void> _scheduleNextInspiration() async {
    final now = tz.TZDateTime.now(tz.local);
    // Find best match for tomorrow
    // Simple logic: Pick a random inspiration item for tomorrow
    final list = NotificationContent.inspiration;
    final item = list[now.second % list.length]; // "Random" based on time seconds for simplicity

    await _zonedSchedule(
      id: item.id,
      title: item.title,
      body: item.body,
      payload: item.payload,
      scheduledDate: _nextInstance(daysOffset: 1, hour: item.hour),
    );
    
    // Check for weekly recurring logic (e.g. if tomorrow is Monday, maybe override?)
    // This can be enhanced later. Currently keeping it simple.
  }

  tz.TZDateTime _nextInstance({required int daysOffset, required int hour}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day + daysOffset, hour);
    
    return scheduledDate;
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    String? payload,
    required tz.TZDateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_inspiration_channel',
          'Daily Inspiration',
          channelDescription: 'Daily sticker ideas and inspiration',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    
    if (kDebugMode) {
      print("Scheduled notification [$id] for $scheduledDate");
    }
  }
}
