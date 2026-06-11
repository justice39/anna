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

  Future<Map<String, dynamic>?> parseNaturalLanguage(String text) async {
    try {
      final response = await _client.functions.invoke(
        'parse-reminder',
        body: {'text': text, 'timezone': DateTime.now().timeZoneName},
      );
      if (response.status != 200) return null;
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
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