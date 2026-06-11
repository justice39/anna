# Anna — Voice Reminder Assistant

Anna is a Flutter mobile app that calls you when it's time for a reminder — like a real phone call, ringing through silent mode for critical alerts. Built for iOS and Android from one codebase.

## What's included in v1

- ✅ Email + Google sign-in via Supabase
- ✅ Create, edit, delete reminders with manual entry
- ✅ **Tap-to-talk voice input** — speak your reminder naturally, AI parses it
- ✅ Two alert modes: standard notification OR full-screen "incoming call" UI
- ✅ Recurrence: once, daily, weekdays, weekly
- ✅ Ringtone picker
- ✅ Quiet hours / Do Not Disturb
- ✅ Dark theme with the warm gold aesthetic from your logo

## What's NOT in v1 (planned for v2)

- ❌ "Hey Anna" always-on wake word (use tap-to-talk for now)
- ❌ iOS Critical Alerts entitlement (apply 4 weeks before launch if you want it)
- ❌ Smart suggestions based on routine
- ❌ Apple Watch / Wear OS companion

---

## Setup steps

### 1. Prerequisites

You need:
- **Flutter SDK** 3.24+ (`flutter --version`)
- **Xcode** (Mac only — for iOS build). **You're on Windows**, so you'll need either:
  - A Mac for iOS builds, OR
  - **Codemagic** or **Bitrise** CI to build iOS in the cloud (recommended for you)
  - Android builds work fine on Windows
- **Android Studio** + Android SDK
- **Apple Developer account** ($99/year) for iOS publishing
- **Google Play Developer account** ($25 one-time) for Android publishing
- A **physical iOS device** for testing CallKit (simulator can't render it)

### 2. Create the project

```bash
# Create a fresh Flutter project
flutter create anna --org com.yourdomain --platforms ios,android

# Replace the generated lib/ with the files from this codebase
# Replace pubspec.yaml with this codebase's pubspec.yaml

cd anna
flutter pub get
```

### 3. Set up Supabase

1. Create a project at supabase.com
2. Run the SQL in `supabase/migrations/001_init.sql` in the SQL editor
3. Enable Google OAuth provider in Authentication → Providers
4. Copy your project URL and anon key
5. Create `lib/env.dart` (gitignored):

```dart
class Env {
  static const supabaseUrl = 'https://YOUR-PROJECT.supabase.co';
  static const supabaseAnonKey = 'YOUR-ANON-KEY';
}
```

### 4. Deploy the reminder-parsing edge function

```bash
# Install Supabase CLI: https://supabase.com/docs/guides/cli
supabase login
supabase link --project-ref YOUR-PROJECT-REF
supabase functions deploy parse-reminder

# Set the Anthropic/OpenAI API key for the edge function
supabase secrets set ANTHROPIC_API_KEY=sk-ant-...
```

### 5. iOS configuration

Open `ios/Runner/Info.plist` and add:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Anna needs microphone access so you can speak your reminders naturally.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Anna uses speech recognition to understand your reminders.</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>voip</string>
</array>
```

In Xcode → Signing & Capabilities, add:
- **Push Notifications**
- **Background Modes** → Audio, Voice over IP
- Apply for **Critical Alerts** entitlement at https://developer.apple.com/contact/request/notifications-critical-alerts/

### 6. Android configuration

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
```

Set `minSdkVersion 23` in `android/app/build.gradle`.

### 7. Run

```bash
# Run with env vars
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY

# Generate freezed/json files
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Timeline (realistic, building it yourself)

| Week | Focus |
|------|-------|
| 1 | Setup, auth, Supabase wiring, navigation |
| 2 | Reminder CRUD, today/all screens, editor |
| 3 | Notifications + CallKit integration (the tricky one) |
| 4 | Voice tap-to-talk + edge function for parsing |
| 5 | Polish, settings, ringtones, onboarding |
| 6 | TestFlight beta, fix bugs |
| 7 | App Store + Play Store submission |

**Apply for Critical Alerts entitlement in week 2** — Apple takes 2–4 weeks to respond. Don't wait until launch week.

---

## File structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root MaterialApp + GoRouter
├── env.dart                     # Your Supabase keys (gitignored)
├── theme/
│   ├── colors.dart              # Dark + gold palette
│   ├── typography.dart          # Instrument Serif + Geist
│   └── theme.dart               # Full ThemeData
├── core/
│   ├── supabase_client.dart
│   ├── notification_service.dart
│   ├── call_service.dart        # CallKit integration
│   ├── voice_service.dart       # Tap-to-talk STT + TTS
│   └── reminder_scheduler.dart
├── models/
│   ├── reminder.dart
│   └── user_profile.dart
├── repositories/
│   └── reminder_repository.dart
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── home/
│   ├── all_reminders/
│   ├── voice/
│   ├── incoming_call/
│   ├── reminder_editor/
│   └── settings/
└── widgets/
    ├── reminder_card.dart
    ├── pulsing_orb.dart
    └── anna_tab_bar.dart
```
