import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/lessons/presentation/lesson_feed_screen.dart';

class StreakLearnApp extends StatelessWidget {
  const StreakLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreakLearn',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LessonFeedScreen(),
      },
    );
  }
}
