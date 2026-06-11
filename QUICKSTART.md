# Anna — Quick-Start Cheat Sheet

The 10-minute version of "what do I do with this codebase?"

## 1. Set up your environment (one-time)

```bash
# Install Flutter — follow https://docs.flutter.dev/get-started/install
# After install, verify:
flutter doctor

# Should see green checkmarks for:
# ✓ Flutter
# ✓ Android toolchain (Android Studio installed)
# ✓ Chrome (for web preview only)
# Yellow/red for Xcode is OK — you're on Windows, use Codemagic instead.
```

## 2. Create the Flutter project shell

```bash
# Pick a folder, then:
flutter create anna --org com.justice --platforms ios,android
cd anna

# Now copy ALL files from this zip into the project, OVERWRITING:
# - pubspec.yaml (replace)
# - lib/ folder (replace entirely with the lib/ from this zip)
# - assets/ folder (copy in)
# - .gitignore (replace)
# - README.md (replace)
# - supabase/ folder (new)
# - ios/INFO_PLIST_ADDITIONS.xml and android/MANIFEST_ADDITIONS.xml are
#   reference files — you MANUALLY merge their contents into Info.plist
#   and AndroidManifest.xml respectively.

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Set up Supabase (15 minutes)

1. Go to https://supabase.com, create a project (free tier is fine).
2. SQL Editor → paste `supabase/migrations/001_init.sql` → run.
3. Authentication → Providers → enable Google (use your OAuth client).
4. Settings → API → copy `Project URL` and `anon public` key.
5. Open `lib/env.dart` and paste both. **Do not commit this file.**

## 4. Deploy the edge function

```bash
npm install -g supabase
supabase login
supabase link --project-ref YOUR-PROJECT-REF
supabase functions deploy parse-reminder
supabase secrets set ANTHROPIC_API_KEY=sk-ant-YOUR-KEY
```

Get an Anthropic API key from https://console.anthropic.com.

## 5. First run (Android)

```bash
# Connect an Android phone or start an emulator
flutter run
```

If it crashes on launch about notifications: grant permissions when prompted, or
go into Android settings → Apps → Anna → Permissions → enable everything.

## 6. iOS — the Windows problem

Since you're on Windows, you can't run `flutter build ios`. Use Codemagic:

1. Push your project to GitHub.
2. Sign up at https://codemagic.io.
3. Connect the repo. Codemagic auto-detects Flutter.
4. In Build Settings:
   - Workflow: Default → Build for iOS
   - Add Apple Developer account credentials
   - Build artifacts: .ipa
5. First build will fail asking for code signing — upload your distribution
   certificate or let Codemagic auto-generate one.
6. After build succeeds, upload .ipa to TestFlight via Codemagic.

**Cost**: Codemagic is free for 500 build minutes/month. Each iOS build is
~15 min, so you get ~30 builds free.

**Alternative**: Borrow a Mac for a weekend, run `flutter build ipa`, upload
once. After that you can update via Codemagic.

## 7. Test the killer feature

The "call" feature only works fully on a **real device**, not the iOS simulator.

To test:
1. Sign in.
2. Hit the + on the All tab to create a reminder.
3. Set scheduled time to 30 seconds from now.
4. Set alert type to "📞 CALL".
5. Save, lock the phone, wait.
6. Phone should ring full-screen like an incoming call. ✨

If it just shows a regular notification: you missed an entitlement in
INFO_PLIST_ADDITIONS or MANIFEST_ADDITIONS. Double-check those.

## 8. Apply for Critical Alerts (do this NOW)

If you want reminders to ring through silent mode on iOS:

1. Go to https://developer.apple.com/contact/request/notifications-critical-alerts/
2. Fill out the form. Position Anna as a health/medication adherence app.
3. Wait 2–4 weeks for Apple's response.

You can ship without this and use "Time Sensitive" interruption level instead —
which rings through Focus mode but not silent. Most users won't notice.

## 9. What's NOT done yet (you'll need to add)

- Real bell_chime.mp3 audio file (assets/sounds/)
- Replace `anna://login-callback/` with your actual scheme in Supabase auth settings
- App icons (use `flutter_launcher_icons` package)
- Splash screen (use `flutter_native_splash`)
- App Store screenshots (use the showcase HTML as reference for the design)
- Privacy policy URL (required for store submission)

## 10. When you get stuck

The error messages from `flutter run` are unusually good — paste them at me and
I'll debug. Common issues:

- **"CocoaPods not installed"** → only matters for Mac builds, ignore on Windows.
- **"Gradle build failed"** → try `cd android && ./gradlew clean` then rebuild.
- **"Realtime not working"** → check Supabase Database → Replication → reminders table is enabled.
- **STT returns empty** → check device microphone permission.
- **CallKit not showing** → must be a physical device, not emulator/simulator.
