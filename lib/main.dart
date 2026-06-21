import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/services/grip_provider.dart';
import 'package:grip_strength_monitor/services/statistics_provider.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';
import 'package:grip_strength_monitor/services/theme_provider.dart';
import 'package:grip_strength_monitor/services/connection_provider.dart';
import 'package:grip_strength_monitor/services/websocket_service.dart';
import 'package:grip_strength_monitor/services/persistence_service.dart';
import 'package:grip_strength_monitor/services/measurement_provider.dart';
import 'package:grip_strength_monitor/services/user_profile_provider.dart';
import 'package:grip_strength_monitor/services/history_provider.dart';
import 'package:grip_strength_monitor/services/achievement_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PersistenceService().init();
  SoundService().init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        Provider(create: (_) => WebSocketService()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(
          create: (context) => GripProvider(
            Provider.of<WebSocketService>(context, listen: false),
            Provider.of<ConnectionProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StatisticsProvider(
            Provider.of<HistoryProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MeasurementProvider(
            Provider.of<WebSocketService>(context, listen: false),
            Provider.of<HistoryProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AchievementProvider(
            Provider.of<HistoryProvider>(context, listen: false),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Grip Strength Monitor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
