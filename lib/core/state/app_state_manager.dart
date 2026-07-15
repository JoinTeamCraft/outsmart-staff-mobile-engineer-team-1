import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_state_event.dart';
import 'quiz_result.dart';

export 'app_state_event.dart';
export 'quiz_result.dart';

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
  bool _disposed = false;

  Set<String> get completedLessonIds => Set.unmodifiable(_completedLessonIds);
  QuizResult? get lastQuizResult => _lastQuizResult;
  int get streakCount => _streakCount;
  DateTime? get lastActivityDate => _lastActivityDate;
  Stream<AppStateEvent> get events => _events.stream;

  bool isLessonCompleted(String lessonId) =>
      _completedLessonIds.contains(lessonId);

  void completeLesson(String lessonId) {
    _checkNotDisposed();
    if (lessonId.trim().isEmpty) {
      throw ArgumentError.value(lessonId, 'lessonId', 'must not be empty');
    }
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
    _checkNotDisposed();
    if (quizId.trim().isEmpty) {
      throw ArgumentError.value(quizId, 'quizId', 'must not be empty');
    }
    if (totalQuestions <= 0) {
      throw ArgumentError.value(
          totalQuestions, 'totalQuestions', 'must be greater than zero');
    }
    if (score < 0 || score > totalQuestions) {
      throw ArgumentError.value(
          score, 'score', 'must be between 0 and totalQuestions');
    }
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
    _checkNotDisposed();
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

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('AppStateManager was used after being disposed');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _events.close();
    super.dispose();
  }
}
