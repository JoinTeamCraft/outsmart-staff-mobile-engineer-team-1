import 'dart:async';

import 'package:flutter/foundation.dart';

sealed class AppStateEvent {
  const AppStateEvent();
}

class LessonCompletedEvent extends AppStateEvent {
  const LessonCompletedEvent(this.lessonId);
  final String lessonId;
}

class QuizCompletedEvent extends AppStateEvent {
  const QuizCompletedEvent(this.result);
  final QuizResult result;
}

class StreakChangedEvent extends AppStateEvent {
  const StreakChangedEvent({required this.previous, required this.current});
  final int previous;
  final int current;
}

class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  double get accuracy => totalQuestions == 0 ? 0 : score / totalQuestions;
  bool get passed => accuracy >= 0.7;
}

/// Single source of truth for lesson completion, quiz results and the daily
/// streak. See STATE_CONTRACT.md for the full contract and usage examples.
class AppStateManager extends ChangeNotifier {
  AppStateManager({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Set<String> _completedLessonIds = {};
  final _events = StreamController<AppStateEvent>.broadcast();

  QuizResult? _lastQuizResult;
  int _streakCount = 0;
  DateTime? _lastActivityDate;

  Set<String> get completedLessonIds => Set.unmodifiable(_completedLessonIds);
  QuizResult? get lastQuizResult => _lastQuizResult;
  int get streakCount => _streakCount;
  DateTime? get lastActivityDate => _lastActivityDate;
  Stream<AppStateEvent> get events => _events.stream;

  bool isLessonCompleted(String lessonId) =>
      _completedLessonIds.contains(lessonId);

  void completeLesson(String lessonId) {
    if (!_completedLessonIds.add(lessonId)) return;
    _events.add(LessonCompletedEvent(lessonId));
    _recordActivity();
    notifyListeners();
  }

  void completeQuiz({
    required String quizId,
    required int score,
    required int totalQuestions,
  }) {
    _lastQuizResult = QuizResult(
      quizId: quizId,
      score: score,
      totalQuestions: totalQuestions,
      completedAt: _clock(),
    );
    _events.add(QuizCompletedEvent(_lastQuizResult!));
    _recordActivity();
    notifyListeners();
  }

  void resetState() {
    final previous = _streakCount;
    _completedLessonIds.clear();
    _lastQuizResult = null;
    _streakCount = 0;
    _lastActivityDate = null;
    if (previous != 0) {
      _events.add(StreakChangedEvent(previous: previous, current: 0));
    }
    notifyListeners();
  }

  // First activity starts the streak at 1, next-day activity increments it,
  // a gap of more than one day resets it to 1, same-day activity is a no-op.
  void _recordActivity() {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final previous = _streakCount;

    if (_lastActivityDate == null) {
      _streakCount = 1;
    } else {
      final gap = today.difference(_lastActivityDate!).inDays;
      if (gap == 0) return;
      _streakCount = gap == 1 ? _streakCount + 1 : 1;
    }
    _lastActivityDate = today;

    if (_streakCount != previous) {
      _events.add(StreakChangedEvent(previous: previous, current: _streakCount));
    }
  }

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}
