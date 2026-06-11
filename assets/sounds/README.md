# Sound assets

Drop your ringtone audio files here. The default reference is `bell_chime`.

## Required files for v1

- `bell_chime.mp3` — Default ringtone (referenced in incoming_call_screen.dart)
- `bell_chime.caf` — iOS-compatible version (Apple's Core Audio Format)
- `bell_chime.wav` — Android raw resource

## Steps to add real sounds

1. Download a royalty-free bell chime from [Pixabay](https://pixabay.com/sound-effects/search/bell/) or [Freesound](https://freesound.org).
2. Save as `bell_chime.mp3` in this folder.
3. For iOS, convert to `.caf`:
   ```bash
   afconvert bell_chime.mp3 bell_chime.caf -d ima4 -f caff
   ```
4. For Android, copy `bell_chime.wav` to `android/app/src/main/res/raw/`.

## Recommendation for Anna

Commission a custom 3-note bell chime — should match the warm/gentle aesthetic.
Soft, friendly, not jarring. Under 5 seconds, will be looped.
