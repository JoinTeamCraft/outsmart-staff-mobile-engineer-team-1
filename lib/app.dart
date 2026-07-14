import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

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
        '/': (context) => const HomeScreenPlaceholder(),
      },
    );
  }
}

class HomeScreenPlaceholder extends StatelessWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StreakLearn')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'Welcome to StreakLearn Hackathon!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Tracks B, C, and D will replace this screen with the Lesson Feed, Lesson Detail/Quiz, and Streak Animation system.',
                textAlign: Center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}