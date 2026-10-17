# StackDialer - Real Native Android Flutter App & APK

StackDialer is a full-fledged native Android dialer replacement application built with Flutter, designed to run with real SIM carrier calling, device contacts, call logs, and system default dialer support.

## Features
- **Real Carrier SIM Calling**: Directly initiates cellular calls from SIM 1 (Jio) or SIM 2 (Airtel) via `flutter_phone_direct_caller`.
- **Real Android Call Logs**: Live device incoming, outgoing, missed, and rejected call logs via `call_log`.
- **Real Device Contacts**: Fetches and searches phone contacts via `flutter_contacts`.
- **Default Dialer Support**: Prompts user to set StackDialer as their primary system phone app using Android `TelecomManager` & `RoleManager`.
- **3D Stacked Card Recents**: 10 animated stack styles with fluid swipe-to-call and swipe-to-delete.
- **T9 Keypad Search**: Rapid dialpad filtering with DTMF dial sounds.

## How to Build the APK

### Method 1: Local Terminal (Requires Flutter & Android Studio)
1. Navigate to the `flutter_app/` folder:
   ```bash
   cd flutter_app
   ```
2. Get packages:
   ```bash
   flutter pub get
   ```
3. Build the release APK:
   ```bash
   flutter build apk --release
   ```
4. Output file will be ready at:
   `build/app/outputs/flutter-apk/app-release.apk`
5. Transfer this `.apk` to your Android phone and tap to install!

### Method 2: 1-Click Free GitHub Cloud Build (Zero local setup required)
1. Push this repository to GitHub.
2. Go to **Actions** tab.
3. Click **"Build StackDialer Android APK"** -> **Run workflow**.
4. In ~2 minutes, download the compiled `StackDialer-Release-APK.zip` directly from GitHub!
