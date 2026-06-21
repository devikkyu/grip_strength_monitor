# AGENTS.md

## Project Overview

Single Flutter app: **Grip Strength Monitor** — healthcare app for elderly users with pet gamification, grip strength measurement via ESP32/HX711 over WebSocket, and rhythm training games. Thai language UI.

## Commands

```bash
flutter pub get
flutter analyze
flutter run
```

No CI. No build scripts. No env loading.

## Architecture (`lib/`)

```
lib/
├── main.dart                          # Entry point, 10 providers (order matters)
├── main_navigation.dart               # Bottom nav (4 tabs: Dashboard, Statistics, Goals, Profile)
├── core/
│   ├── theme/app_theme.dart           # Purple theme (#6C4DF6), light/dark, Sarabun font
│   ├── constants/app_localizations.dart  # Thai strings (th map)
│   └── utils/animations.dart          # fadeSlideUp, pulse, luxuryGradient helpers
├── features/
│   ├── splash/splash_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── statistics/statistics_screen.dart
│   ├── goals/goals_screen.dart        # Pet cat + daily tasks
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   ├── measurement/grip_measurement_screen.dart
│   ├── training/
│   │   └── guided_training_screen.dart  # 3 difficulty levels + metronome
│   ├── smart_rhythm/smart_rhythm_screen.dart  # Metronome trainer
│   ├── game/
│   │   ├── grip_rhythm_game_screen.dart  # Piano Tiles style
│   │   ├── music_rhythm_screen.dart      # Audio-driven rhythm game
│   │   ├── music_selection_screen.dart   # Song picker
│   │   ├── services/
│   │   │   ├── audio_manager.dart     # Single audio player
│   │   │   ├── beatmap_generator.dart  # BPM-based beat maps
│   │   │   └── music_library.dart     # Song manifest
│   │   ├── models/song_data.dart      # SongData + BeatNote
│   │   └── widgets/
│   │       ├── connection_dialog.dart
│   │       └── game_over_dialog.dart
│   ├── history/training_history_screen.dart
│   ├── streak/streak_calendar_screen.dart
│   ├── report/health_report_screen.dart
│   └── achievements/achievements_screen.dart
├── services/
│   ├── grip_provider.dart
│   ├── todo_provider.dart
│   ├── statistics_provider.dart
│   ├── theme_provider.dart
│   ├── measurement_provider.dart
│   ├── connection_provider.dart
│   ├── history_provider.dart
│   ├── user_profile_provider.dart
│   ├── achievement_provider.dart
│   ├── websocket_service.dart         # WebSocket for ESP32 real-time data
│   ├── persistence_service.dart       # Hive local storage (6 boxes)
│   └── sound_service.dart             # Haptic feedback
└── shared/models/
    ├── grip_data.dart
    ├── todo.dart
    ├── training_session.dart
    └── achievement.dart
```

## Conventions

- **State management**: `provider` (ChangeNotifier + Consumer). 10 providers in `main.dart`.
- **Provider order is critical**: `HistoryProvider` MUST be registered before `StatisticsProvider`, `MeasurementProvider`, and `AchievementProvider`.
- **Theme**: Purple `#6C4DF6` as primary. Use `.withValues(alpha:)` — never `.withOpacity()`.
- **Font**: Sarabun via `google_fonts`. Thai UI via `AppLocalizations.get('key')`.
- **Feature-based structure** under `lib/features/`.
- **Persistence**: `hive` + `hive_flutter`. `PersistenceService` handles init and access.
- **ESP32 connection**: WebSocket via `web_socket_channel`. `ConnectionProvider` manages state.
- **Audio**: `just_audio` for local MP3 playback. No YouTube dependency.
- **ListTile warning**: Wrap in `Material(color: Colors.transparent, child: ListTile(...))` when inside a Container with background color.
- **Every visible button must work** — no `onTap: () {}`, no TODOs, no dead navigation.

## Dependencies

- `provider` — state management
- `google_fonts` — Sarabun font
- `just_audio` + `audio_session` — local audio playback
- `web_socket_channel` — WebSocket for ESP32
- `hive` + `hive_flutter` — local persistence

## Test

Minimal — single `widget_test.dart`. No integration tests. No CI.
