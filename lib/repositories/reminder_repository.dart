import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reminder.dart';
import '../core/notification_service.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(Supabase.instance.client);
});

final remindersStreamProvider = FutureProvider<List<Reminder>>((ref) async {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.fetchAll();
});

class ReminderRepository {
  ReminderRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<Reminder>> fetchAll() async {
    final rows = await _client
        .from('reminders')
        .select()
        .eq('user_id', _uid)
        .order('scheduled_at', ascending: true);
    return (rows as List)
        .map((row) => _fromRow(row as Map<String, dynamic>))
        .toList();
  }

  Future<Reminder> create(Reminder reminder) async {
    final row = await _client
        .from('reminders')
        .insert(_toRow(reminder, includeUserId: true))
        .select()
        .single();
    final saved = _fromRow(row);
    await NotificationService.instance.schedule(saved);
    return saved;
  }

  Future<Reminder> update(Reminder reminder) async {
    final row = await _client
        .from('reminders')
        .update(_toRow(reminder))
        .eq('id', reminder.id)
        .select()
        .single();
    final saved = _fromRow(row);
    await NotificationService.instance.cancel(saved.id);
    if (saved.isActive) await NotificationService.instance.schedule(saved);
    return saved;
  }

  Future<void> delete(String id) async {
    await NotificationService.instance.cancel(id);
    await _client.from('reminders').delete().eq('id', id);
  }

  Future<Reminder?> getById(String id) async {
    final row = await _client
        .from('reminders')
        .select()
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  /// Local natural-language parser. Works offline, no backend needed.
  Future<Map<String, dynamic>?> parseNaturalLanguage(String text) async {
    final lower = text.toLowerCase().trim();
    if (lower.isEmpty) return null;

    final now = DateTime.now();
    DateTime? when;
    String recurrence = 'none';

    // alert type: "call me" / "call" => call, else alert
    final alertType = lower.contains('call') ? 'call' : 'alert';

    // recurrence
    if (lower.contains('every day') || lower.contains('daily')) {
      recurrence = 'daily';
    } else if (lower.contains('weekday')) {
      recurrence = 'weekdays';
    } else if (lower.contains('every week') || lower.contains('weekly')) {
      recurrence = 'weekly';
    }

    // "in X minutes/hours"
    final inMatch =
        RegExp(r'in (\d+)\s*(minute|min|hour|hr)').firstMatch(lower);
    if (inMatch != null) {
      final amount = int.parse(inMatch.group(1)!);
      final unit = inMatch.group(2)!;
      when = unit.startsWith('h')
          ? now.add(Duration(hours: amount))
          : now.add(Duration(minutes: amount));
    }

    // "at 3pm" / "at 9am" / "at 3:30pm"
    if (when == null) {
      final atMatch =
          RegExp(r'at (\d{1,2})(?::(\d{2}))?\s*(am|pm)?').firstMatch(lower);
      if (atMatch != null) {
        var hour = int.parse(atMatch.group(1)!);
        final minute =
            atMatch.group(2) != null ? int.parse(atMatch.group(2)!) : 0;
        final period = atMatch.group(3);
        if (period == 'pm' && hour < 12) hour += 12;
        if (period == 'am' && hour == 12) hour = 0;

        var candidate = DateTime(now.year, now.month, now.day, hour, minute);
        if (lower.contains('tomorrow') || candidate.isBefore(now)) {
          candidate = candidate.add(const Duration(days: 1));
        }
        when = candidate;
      }
    }

    // fallback: 1 hour from now if no time found
    when ??= now.add(const Duration(hours: 1));

    // build a clean title
    var title = text.trim();
    title = title.replaceAll(
        RegExp(
            r'(remind me to|remind me|call me to|call me at|call me|in \d+\s*(minutes?|mins?|hours?|hrs?)|at \d{1,2}(:\d{2})?\s*(am|pm)?|every day|daily|tomorrow|weekdays?|weekly|every week)',
            caseSensitive: false),
        '');
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (title.isEmpty) title = 'Reminder';
    title = title[0].toUpperCase() + title.substring(1);

    return {
      'title': title,
      'notes': null,
      'scheduled_at': when.toIso8601String(),
      'recurrence': recurrence,
      'alert_type': alertType,
    };
  }

  Map<String, dynamic> _toRow(Reminder r, {bool includeUserId = false}) {
    final row = <String, dynamic>{
      'id': r.id,
      'title': r.title,
      'notes': r.notes,
      'scheduled_at': r.scheduledAt.toUtc().toIso8601String(),
      'recurrence': r.recurrence.name,
      'alert_type': r.alertType.name,
      'is_active': r.isActive,
      'is_critical': r.isCritical,
      'ringtone': r.ringtone,
    };
    if (includeUserId) row['user_id'] = _uid;
    return row;
  }

  Reminder _fromRow(Map<String, dynamic> row) {
    return Reminder(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      title: row['title'] as String,
      notes: row['notes'] as String?,
      scheduledAt: DateTime.parse(row['scheduled_at'] as String),
      recurrence: _parseRecurrence(row['recurrence'] as String?),
      alertType:
          row['alert_type'] == 'call' ? AlertType.call : AlertType.alert,
      isActive: row['is_active'] as bool? ?? true,
      isCritical: row['is_critical'] as bool? ?? false,
      ringtone: (row['ringtone'] as String?) ?? 'bell_chime',
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  Recurrence _parseRecurrence(String? raw) {
    switch (raw) {
      case 'daily':
        return Recurrence.daily;
      case 'weekdays':
        return Recurrence.weekdays;
      case 'weekly':
        return Recurrence.weekly;
      default:
        return Recurrence.none;
    }
  }
}