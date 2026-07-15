import 'quiz_result.dart';

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
