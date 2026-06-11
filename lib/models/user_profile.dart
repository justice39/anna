import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    String? displayName,
    String? email,
    @Default(true) bool wakeWordEnabled, // For v2
    @Default(true) bool callAlertsEnabled,
    @Default(true) bool persistentRing,
    @Default('bell_chime') String defaultRingtone,
    @Default(true) bool doNotDisturbEnabled,
    @Default('22:00') String quietHoursStart,
    @Default('07:00') String quietHoursEnd,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
