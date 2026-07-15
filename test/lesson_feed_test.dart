import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:streaklearn/core/di/service_locator.dart';
import 'package:streaklearn/core/state/app_state_manager.dart';
import 'package:streaklearn/features/lessons/data/lesson_repository.dart';
import 'package:streaklearn/features/lessons/presentation/lesson_feed_controller.dart';
import 'package:streaklearn/features/lessons/presentation/lesson_feed_screen.dart';

import 'lesson_repository_test.dart' show FakeApiClient;

Future<void> pumpFeed(WidgetTester tester, AppStateManager state) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: state,
      child: const MaterialApp(home: LessonFeedScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late FakeApiClient api;
  late AppStateManager state;

  setUp(() {
    api = FakeApiClient();
    locator.registerLazySingleton<LessonRepository>(
      () => LessonRepository(apiClient: api),
    );
    state = AppStateManager();
  });

  tearDown(() async {
    await locator.reset();
    state.dispose();
  });

  group('LessonFeedController', () {
    test('exposes loaded lessons after load', () async {
      final controller =
          LessonFeedController(repository: locator<LessonRepository>());
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.status, FeedStatus.loaded);
      expect(controller.lessons, hasLength(2));
    });

    test('refresh bypasses the cache', () async {
      final controller =
          LessonFeedController(repository: locator<LessonRepository>());
      addTearDown(controller.dispose);

      await controller.load();
      await controller.refresh();

      expect(api.fetchCount, 2);
    });

    test('reports error status when the fetch fails', () async {
      final controller = LessonFeedController(
        repository: LessonRepository(apiClient: _AlwaysFailingApiClient()),
      );
      addTearDown(controller.dispose);

      await controller.load();

      expect(controller.status, FeedStatus.error);
      expect(controller.error, isNotNull);
    });
  });

  group('LessonFeedScreen', () {
    testWidgets('renders lessons from the active state via ListView.builder',
        (tester) async {
      await pumpFeed(tester, state);

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Flutter Basics'), findsOneWidget);
      expect(find.text('Async Dart'), findsOneWidget);
      expect(find.text('Fundamentals'), findsOneWidget);
      expect(api.fetchCount, 1);
    });

    testWidgets('shows a completed badge from AppStateManager', (tester) async {
      state.completeLesson('lesson-1');
      await pumpFeed(tester, state);

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('pull-to-refresh bypasses the cache', (tester) async {
      await pumpFeed(tester, state);

      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(api.fetchCount, 2);
    });
  });
}

class _AlwaysFailingApiClient extends FakeApiClient {
  @override
  Future<String> getLessonsRaw() => Future.error(Exception('network down'));
}
