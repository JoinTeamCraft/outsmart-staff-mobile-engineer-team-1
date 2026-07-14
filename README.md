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

## Running the App
1. Make sure Flutter SDK is installed.
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Development & Collaboration Rules
- **No Direct Commits to `main`:** All work must be done on track-specific branches (e.g., `track-a/data-layer`).
- **PR Review Policy:** Every PR must be reviewed by at least one teammate.
- **AI-Inspectable Artifacts:** Follow the requirements defined in your tickets carefully. Your code, tests, and configuration will be programmatically reviewed by an automated grading system."# streaklearn-starter" 
