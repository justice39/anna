import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

enum AlertType {
  @JsonValue('alert')
  alert,
  @JsonValue('call')
  call,
}

enum Recurrence {
  @JsonValue('none')
  none,
  @JsonValue('daily')
  daily,
  @JsonValue('weekdays')
  weekdays,
  @JsonValue('weekly')
  weekly,
}

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String userId,
    required String title,
    String? notes,
    required DateTime scheduledAt,
    @Default(Recurrence.none) Recurrence recurrence,
    @Default(AlertType.alert) AlertType alertType,
    @Default(true) bool isActive,
    @Default(false) bool isCritical,
    @Default('bell_chime') String ringtone,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}

extension ReminderX on Reminder {
  bool get isCall => alertType == AlertType.call;

  String get recurrenceLabel {
    switch (recurrence) {
      case Recurrence.none:
        return 'Once';
      case Recurrence.daily:
        return 'Daily';
      case Recurrence.weekdays:
        return 'Weekdays';
      case Recurrence.weekly:
        return 'Weekly';
    }
  }

  Duration get timeUntil => scheduledAt.difference(DateTime.now());

  bool get isImminent =>
      timeUntil.inMinutes >= 0 && timeUntil.inMinutes <= 30;
}
