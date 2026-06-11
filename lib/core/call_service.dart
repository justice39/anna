import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';

import '../models/reminder.dart';

/// Wraps flutter_callkit_incoming to show full-screen "incoming call" UI when
/// a reminder fires with alert_type = 'call'.
class CallService {
  CallService._();
  static final instance = CallService._();

  final _uuid = const Uuid();
  StreamSubscription? _eventSub;

  /// Called from main.dart on app start.
  Future<void> init() async {
    _eventSub = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
  }

  void dispose() {
    _eventSub?.cancel();
  }

  /// Shows the incoming-call UI immediately for a fired reminder.
  Future<void> showIncomingCall(Reminder reminder) async {
    final params = CallKitParams(
      id: reminder.id,
      nameCaller: 'Anna',
      appName: 'Anna',
      avatar: 'https://i.imgur.com/anna-logo.png', // Replace with hosted logo URL
      handle: reminder.title,
      type: 0, // 0 = audio
      duration: 30000, // ring for 30 seconds
      textAccept: 'Answer',
      textDecline: 'Dismiss',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed reminder',
      ),
      extra: {'reminderId': reminder.id, 'title': reminder.title},
      headers: const {},
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0A0A0C',
        backgroundUrl: '',
        actionColor: '#F5B942',
        textColor: '#F5F0E6',
        incomingCallNotificationChannelName: 'Anna Reminder Calls',
        missedCallNotificationChannelName: 'Anna Missed Reminders',
        isShowFullLockedScreen: true,
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  /// Native scheduling not directly supported by the package — we still
  /// register a local-notification fallback in NotificationService. This
  /// stub is here so callers can express intent symmetrically.
  Future<void> scheduleCall(Reminder reminder) async {
    if (kDebugMode) {
      debugPrint('[CallService] schedule call for ${reminder.id} '
          'at ${reminder.scheduledAt}');
    }
  }

  Future<void> cancel(String reminderId) async {
    await FlutterCallkitIncoming.endCall(reminderId);
  }

  Future<void> endAll() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  void _handleEvent(CallEvent? event) {
    if (event == null) return;
    switch (event.event) {
      case Event.actionCallAccept:
        // User answered — your router can navigate to the in-call screen.
        break;
      case Event.actionCallDecline:
      case Event.actionCallTimeout:
      case Event.actionCallEnded:
        // Stop ringing, record the dismissal.
        break;
      default:
        break;
    }
  }
}
