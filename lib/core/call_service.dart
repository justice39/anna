import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../models/reminder.dart';
import 'notification_service.dart';

/// Wraps flutter_callkit_incoming to show full-screen "incoming call" UI when
/// a reminder fires with alert_type = 'call'.
class CallService {
  CallService._();
  static final instance = CallService._();

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
      handle: reminder.title,
      type: 0,
      duration: 30000,
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

  Future<void> cancel(String reminderId) async {
    await FlutterCallkitIncoming.endCall(reminderId);
  }

  Future<void> endAll() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  void _handleEvent(CallEvent? event) {
    if (event == null) return;
    debugPrint('[CallService] event: ${event.event}');
    switch (event.event) {
      case Event.actionCallAccept:
        // User answered — navigate to the in-call screen where Anna speaks.
        final id = event.body['extra']?['reminderId'] as String? ??
            event.body['id'] as String?;
        if (id != null) {
          navigatorKey.currentState?.pushNamed('/incoming-call/$id');
        }
        break;
      case Event.actionCallDecline:
      case Event.actionCallTimeout:
      case Event.actionCallEnded:
        // Ringing stops automatically; nothing else needed for v1.
        break;
      default:
        break;
    }
  }
}