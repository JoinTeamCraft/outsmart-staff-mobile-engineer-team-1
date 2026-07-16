import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:streaklearn/core/di/service_locator.dart';
import 'package:streaklearn/core/state/app_state_manager.dart';
import 'package:streaklearn/features/streaks/presentation/streak_celebration_listener.dart';

/// Two frames: state events are delivered in a microtask, so the setState
/// they trigger can land after the first frame a single pump builds.
Future<void> pumpEvent(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

/// Mirrors the production wiring in main.dart: the manager is provided
/// above MaterialApp and the listener resolves it from the widget tree.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: locator<AppStateManager>(),
      child: MaterialApp(
        builder: (context, child) => StreakCelebrationListener(
          child: child ?? const SizedBox.shrink(),
        ),
        home: const Scaffold(body: Text('home')),
      ),
    ),
  );
}

void main() {
  setUp(setupLocator);
  tearDown(() => locator.reset());

  testWidgets('completing a quiz fires the celebration end-to-end',
      (tester) async {
    await pumpApp(tester);
    expect(find.byIcon(Icons.local_fire_department), findsNothing);

    locator<AppStateManager>().completeQuiz(
      quizId: 'quiz-1',
      score: 5,
      totalQuestions: 5,
    );
    await pumpEvent(tester);

    expect(find.text('1 day streak!'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
  });

  testWidgets('banner dismisses itself and does not re-trigger on rebuild',
      (tester) async {
    await pumpApp(tester);
    locator<AppStateManager>().completeLesson('lesson-1');
    await pumpEvent(tester);

    expect(find.text('1 day streak!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    expect(find.text('1 day streak!'), findsNothing);

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1 day streak!'), findsNothing,
        reason: 'rebuilds must not replay one-shot events');
  });

  testWidgets('same-day quiz shows the quiz message without a streak change',
      (tester) async {
    await pumpApp(tester);
    final state = locator<AppStateManager>();
    state.completeLesson('lesson-1');
    await tester.pump(const Duration(seconds: 3));

    state.completeQuiz(quizId: 'quiz-1', score: 4, totalQuestions: 5);
    await pumpEvent(tester);

    expect(find.text('Quiz passed 4/5!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('unmounting during the display window does not throw',
      (tester) async {
    await pumpApp(tester);
    locator<AppStateManager>().completeLesson('lesson-1');
    await pumpEvent(tester);
    expect(find.text('1 day streak!'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed quiz does not celebrate', (tester) async {
    await pumpApp(tester);
    final state = locator<AppStateManager>();
    state.completeLesson('lesson-1');
    await tester.pump(const Duration(seconds: 3));

    state.completeQuiz(quizId: 'quiz-1', score: 1, totalQuestions: 5);
    await pumpEvent(tester);

    expect(find.text('Quiz passed 1/5!'), findsNothing);
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
  });
}
