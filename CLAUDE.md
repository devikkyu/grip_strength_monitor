# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Run App**: `flutter run`
- **Analyze Code**: `flutter analyze`
- **Run All Tests**: `flutter test`
- **Run Specific Test**: `flutter test test/path/to_test.dart`
- **Build APK**: `flutter build apk`

## Architecture & Structure

The project follows a feature-first architecture with centralized state management using the `provider` package.

### Core Layers
- `lib/main.dart`: Application entry point. Initializes `PersistenceService` and configures the `MultiProvider` tree.
- `lib/core/`: Shared infrastructure.
    - `theme/`: App-wide styling (Primary Pink `#FF6B9D`).
    - `constants/`: Thai language localizations via `AppLocalizations`.
- `lib/features/`: Feature-specific UI and logic. Each folder contains its own screens and widgets (e.g., `dashboard`, `measurement`, `game`).
- `lib/services/`: Business logic and state providers (`ChangeNotifier`). 
    - Most providers synchronize with `PersistenceService` (Hive) for local storage.
    - `WebSocketService` handles real-time grip data from ESP32.
- `lib/shared/models/`: Shared data entities (e.g., `GripData`, `TrainingSession`).

### Key Technical Decisions
- **State Management**: Heavy reliance on `Provider` and `Consumer` for reactive UI.
- **Local Persistence**: `Hive` is used via `PersistenceService` for high-performance key-value storage of user profiles, settings, and history.
- **Hardware Communication**: Uses WebSockets (`ws://<ip>:80`) for real-time grip strength data. 
    - **Payload Format**: JSON `{"grip": double, "timestamp": int}`.
- **Theme Constraints**: Use `.withValues(alpha:)` for colors; never use `.withOpacity()`. Font is Sarabun via `google_fonts`.

## Conventions
- **UI Language**: Thai. Use `AppLocalizations.get('key')` for all user-facing text.
- **ListTile Warning**: When placing `ListTile` inside a `Container` with a background color, it must be wrapped in `Material(color: Colors.transparent, child: ListTile(...))` to avoid background artifacts.
- **Data Flow**: UI $\rightarrow$ Provider $\rightarrow$ PersistenceService $\rightarrow$ Hive.
