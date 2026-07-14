# StreakLearn - Hackathon Starter Project

Welcome to the **StreakLearn** mobile engineer hiring hackathon! This is the starter repository that all teams will build upon.

## Project Structure
The repository is structured with modular feature folders:
```text
streaklearn/
├── lib/
│   ├── app.dart                  <- Routing and application configuration
│   ├── core/                     <- Shared modules, network clients, DI
│   ├── features/                 <- Modular feature directories
│   │   ├── lessons/              <- Track A & B
│   │   ├── quiz/                 <- Track C
│   │   └── streaks/              <- Track D
│   └── shared/                   <- Common UI widgets and themes
```

## Getting Started

### Prerequisites
- **Flutter SDK** (stable channel). Verify with `flutter --version`.
- **Web:** Google Chrome — no extra toolchain required (easiest target for iteration).
- **Android:** Android Studio + Android SDK, and a running emulator or connected device.
- **iOS/macOS:** Full **Xcode** (from the App Store) plus **CocoaPods** (`brew install cocoapods`), and a simulator or connected device.

Run `flutter doctor` to confirm the toolchains for your target platform are set up.

### Running the App
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. List available devices:
   ```bash
   flutter devices
   ```
3. Run on a specific target:
   ```bash
   flutter run -d chrome   # web (fastest to start)
   flutter run -d macos    # macOS desktop
   flutter run             # or pick from the device list if only one is connected
   ```

> The repo already includes the `android/`, `ios/`, `web/`, and `macos/` platform folders, so no `flutter create` step is needed.

## Development & Collaboration Rules
- **No Direct Commits to `main`:** All work must be done on track-specific branches (e.g., `track-a/data-layer`).
- **PR Review Policy:** Every PR must be reviewed by at least one teammate.
- **AI-Inspectable Artifacts:** Follow the requirements defined in your tickets carefully. Your code, tests, and configuration will be programmatically reviewed by an automated grading system."# streaklearn-starter" 
