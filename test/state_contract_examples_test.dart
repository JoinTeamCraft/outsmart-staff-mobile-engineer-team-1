import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:streaklearn/core/di/service_locator.dart';
import 'package:streaklearn/core/state/app_state_manager.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateManager>();
    return Text('${state.streakCount} day streak');
  }
}

void main() {
  group('AppStateManager', () {
    test('completeLesson is idempotent and emits one event', () async {
      final state = AppStateManager();
      final events = <AppStateEvent>[];
      final sub = state.events.listen(events.add);
      addTearDown(sub.cancel);

      state.completeLesson('lesson_1');
      state.completeLesson('lesson_1');
      await Future<void>.delayed(Duration.zero);

      expect(state.completedLessonIds, {'lesson_1'});
      expect(state.isLessonCompleted('lesson_1'), isTrue);
      expect(events.whereType<LessonCompletedEvent>().length, 1);
    });

    test('completeQuiz stores result with accuracy and pass mark', () {
      final state = AppStateManager(clock: () => DateTime(2026, 7, 14));

      state.completeQuiz(
        quizId: 'quiz_flutter_basics',
        score: 4,
        totalQuestions: 5,
      );

      final result = state.lastQuizResult!;
      expect(result.quizId, 'quiz_flutter_basics');
      expect(result.accuracy, 0.8);
      expect(result.passed, isTrue);
      expect(result.completedAt, DateTime(2026, 7, 14));
    });

    test('streak increments on consecutive days and resets after a gap', () {
      var today = DateTime(2026, 7, 14);
      final state = AppStateManager(clock: () => today);

      state.completeLesson('l1');
      expect(state.streakCount, 1);

      state.completeLesson('l2');
      expect(state.streakCount, 1, reason: 'same-day activity is a no-op');

      today = DateTime(2026, 7, 15);
      state.completeLesson('l3');
      expect(state.streakCount, 2);

      today = DateTime(2026, 7, 18);
      state.completeLesson('l4');
      expect(state.streakCount, 1, reason: 'gap over one day resets streak');
    });

    test('rejects invalid input with ArgumentError', () {
      final state = AppStateManager();

      expect(() => state.completeLesson('   '), throwsArgumentError);
      expect(
        () => state.completeQuiz(quizId: '', score: 1, totalQuestions: 5),
        throwsArgumentError,
      );
      expect(
        () => state.completeQuiz(quizId: 'q1', score: 0, totalQuestions: 0),
        throwsArgumentError,
      );
      expect(
        () => state.completeQuiz(quizId: 'q1', score: 6, totalQuestions: 5),
        throwsArgumentError,
      );
      expect(state.completedLessonIds, isEmpty);
      expect(state.lastQuizResult, isNull);
    });

    test('resetState clears progress and emits StreakChangedEvent', () async {
      final state = AppStateManager();
      final events = <AppStateEvent>[];
      final sub = state.events.listen(events.add);
      addTearDown(sub.cancel);

      state.completeLesson('lesson_1');
      state.resetState();
      await Future<void>.delayed(Duration.zero);

      expect(state.completedLessonIds, isEmpty);
      expect(state.lastQuizResult, isNull);
      expect(state.streakCount, 0);
      expect(state.lastActivityDate, isNull);
      expect(events.last, isA<StreakChangedEvent>());
    });
  });

  test('locator reset disposes the manager and further use throws', () async {
    setupLocator();
    setupLocator();
    final manager = locator<AppStateManager>();
    await locator.reset();

    expect(() => manager.completeLesson('lesson-1'), throwsStateError);
  });

  testWidgets('contract widget example reads streak via provider',
      (tester) async {
    final state = AppStateManager();
    state.completeLesson('lesson_1');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: StreakBadge()),
      ),
    );

    expect(find.text('1 day streak'), findsOneWidget);
  });
}
