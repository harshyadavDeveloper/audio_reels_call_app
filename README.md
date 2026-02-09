# 🎧 Audio Reels & Calls (Flutter)

A Flutter app that combines **reels-style audio playback** with **real-time voice calls**.

## ✨ Features
- Vertical audio reels (Shorts-style)
- Tap to pause / resume with overlay
- Auto-play on scroll
- Incoming call UI (Accept / Decline)
- Audio pauses during calls and resumes after
- Background / foreground call notifications

## 🛠 Tech Stack
- Flutter & Dart
- flutter_bloc (state management)
- just_audio + audio_session (audio playback)
- Agora RTC Engine (real-time calls)
- flutter_local_notifications (call notifications)

## ⚙️ SDK & Environment

| Tool | Version |
|-----|--------|
| **Flutter SDK** | `>= 3.2.0 < 4.0.0` |
| **Dart SDK** | Bundled with Flutter 3.2+ |
| **Java (Android)** | Java 17 |
| **Android Gradle Plugin** | Compatible with Flutter 3.x |

### Why these versions?
- **Flutter 3.2+**  
  Used for stable Material 3 support, improved performance, and compatibility with modern plugins like Agora and just_audio.
- **Dart 3.x**  
  Enables sound null safety and better compile-time checks, reducing runtime crashes.
- **Java 17**  
  Required by newer Android Gradle Plugin versions and recommended by Flutter for Android builds.
- **Real device recommended**  
  Background audio and call behavior cannot be reliably tested on emulators.

## ▶️ Run Locally
```bash
flutter pub get
flutter run
