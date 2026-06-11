import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/reminder.dart';
import 'call_service.dart';

/// Global key so notifications can navigate even when tapped from background.
final navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onTap,
    );

    await _android?.deleteNotificationChannel('anna_calls');
    await _android?.deleteNotificationChannel('anna_alerts');

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'anna_calls',
        'Anna Calls',
        description: 'Full-screen reminder calls from Anna',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );

    await _android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'anna_alerts',
        'Anna Alerts',
        description: 'Standard reminder alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
  }

  /// Checks if the app was launched by tapping a notification (cold start).
  Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse?.payload;
    }
    return null;
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final granted = await _ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    } else if (Platform.isAndroid) {
      final notif = await _android?.requestNotificationsPermission();
      final exact = await _android?.requestExactAlarmsPermission();
      return (notif ?? false) && (exact ?? false);
    }
    return false;
  }

  Future<void> schedule(Reminder reminder) async {
    if (!reminder.isActive) return;

    final localTime = reminder.scheduledAt.toLocal();
    if (localTime.isBefore(DateTime.now()) && reminder.recurrence == Recurrence.none) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(localTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      reminder.isCall ? 'anna_calls' : 'anna_alerts',
      reminder.isCall ? 'Anna Calls' : 'Anna Alerts',
      channelDescription: reminder.isCall ? 'Full-screen reminder calls from Anna' : 'Standard reminder alerts',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: reminder.isCall,
      category: reminder.isCall ? AndroidNotificationCategory.call : AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      audioAttributesUsage: reminder.isCall ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      additionalFlags: reminder.isCall ? Int32List.fromList(<int>[4]) : null,
      ongoing: reminder.isCall,
      autoCancel: !reminder.isCall,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: reminder.isCritical ? InterruptionLevel.critical : InterruptionLevel.timeSensitive,
    );

    await _plugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.isCall ? 'Anna' : reminder.title,
      reminder.isCall ? reminder.title : (reminder.notes ?? 'Reminder'),
      scheduledDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _recurrenceComponents(reminder.recurrence),
      payload: '${reminder.isCall ? "call" : "alert"}:${reminder.id}',
    );
  }

  Future<void> cancel(String reminderId) async {
    await _plugin.cancel(reminderId.hashCode);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Stops a currently-ringing call notification.
  Future<void> stopRinging(String reminderId) async {
    await _plugin.cancel(reminderId.hashCode);
  }

  DateTimeComponents? _recurrenceComponents(Recurrence r) {
    switch (r) {
      case Recurrence.none:
        return null;
      case Recurrence.daily:
        return DateTimeComponents.time;
      case Recurrence.weekly:
      case Recurrence.weekdays:
        return DateTimeComponents.dayOfWeekAndTime;
    }
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    _route(payload);
  }

  static void _route(String payload) {
    final parts = payload.split(':');
    if (parts.length != 2) return;
    final type = parts[0];
    final id = parts[1];
    if (type == 'call') {
      navigatorKey.currentState?.pushNamed('/incoming-call/$id');
    }
  }
}