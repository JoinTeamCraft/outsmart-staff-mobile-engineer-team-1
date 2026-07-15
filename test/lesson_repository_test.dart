import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:streaklearn/core/cache/memory_cache.dart';
import 'package:streaklearn/core/di/service_locator.dart';
import 'package:streaklearn/core/network/api_client.dart';
import 'package:streaklearn/features/lessons/data/lesson_repository.dart';

const lessonsJson = '''
[
  {
    "id": "lesson-1",
    "title": "Flutter Basics",
    "topic": "Fundamentals",
    "thumbnail": "thumb1.png",
    "content": "Everything is a widget."
  },
  {
    "id": "lesson-2",
    "title": "Async Dart",
    "topic": "Dart",
    "thumbnail": "thumb2.png",
    "content": "Futures and Streams."
  }
]
''';

class FakeApiClient extends ApiClient {
  int fetchCount = 0;

  @override
  Future<String> getLessonsRaw() async {
    fetchCount++;
    return lessonsJson;
  }
}

void main() {
  group('MemoryCache', () {
    test('returns stored value before ttl and null after expiry', () {
      var now = DateTime(2026, 7, 15, 10);
      final cache = MemoryCache<String, int>(
        ttl: const Duration(minutes: 5),
        clock: () => now,
      );

      cache.set('key', 42);
      expect(cache.get('key'), 42);

      now = now.add(const Duration(minutes: 5));
      expect(cache.get('key'), isNull);
    });

    test('invalidate removes a single entry', () {
      final cache = MemoryCache<String, int>();
      cache.set('key', 1);
      cache.invalidate('key');
      expect(cache.get('key'), isNull);
    });
  });

  group('LessonRepository', () {
    test('repeat calls are served from cache with a single fetch', () async {
      final api = FakeApiClient();
      final repo = LessonRepository(apiClient: api);

      final first = await repo.getLessons();
      final second = await repo.getLessons();

      expect(first, hasLength(2));
      expect(second, same(first));
      expect(api.fetchCount, 1);
    });

    test('concurrent calls share one in-flight request', () async {
      final api = FakeApiClient();
      final repo = LessonRepository(apiClient: api);

      final results = await Future.wait([
        repo.getLessons(),
        repo.getLessons(),
        repo.getLessons(),
      ]);

      expect(results, everyElement(hasLength(2)));
      expect(api.fetchCount, 1);
    });

    test('forceRefresh bypasses the cache', () async {
      final api = FakeApiClient();
      final repo = LessonRepository(apiClient: api);

      await repo.getLessons();
      await repo.getLessons(forceRefresh: true);

      expect(api.fetchCount, 2);
    });

    test('expired cache triggers a refetch', () async {
      var now = DateTime(2026, 7, 15, 10);
      final api = FakeApiClient();
      final repo = LessonRepository(
        apiClient: api,
        cache: MemoryCache(ttl: const Duration(minutes: 5), clock: () => now),
      );

      await repo.getLessons();
      now = now.add(const Duration(minutes: 6));
      await repo.getLessons();

      expect(api.fetchCount, 2);
    });

    test('getLessonById resolves from the cached list', () async {
      final api = FakeApiClient();
      final repo = LessonRepository(apiClient: api);

      final lesson = await repo.getLessonById('lesson-2');
      final missing = await repo.getLessonById('lesson-99');

      expect(lesson?.title, 'Async Dart');
      expect(missing, isNull);
      expect(api.fetchCount, 1);
    });

    test('completed fetch does not drop a newer force-refresh request',
        () async {
      final api = ControlledApiClient();
      final repo = LessonRepository(apiClient: api);

      final first = repo.getLessons();
      final second = repo.getLessons(forceRefresh: true);
      expect(api.completers, hasLength(2));

      api.completers[0].complete(lessonsJson);
      await first;

      final third = repo.getLessons();
      expect(api.completers, hasLength(2),
          reason: 'third call must join the in-flight refresh');

      api.completers[1].complete(lessonsJson);
      expect(await second, hasLength(2));
      expect(await third, hasLength(2));
    });

    test('malformed lesson JSON throws FormatException', () async {
      final api = _MalformedApiClient();
      final repo = LessonRepository(apiClient: api);

      await expectLater(repo.getLessons(), throwsFormatException);
    });

    test('getLessonById rejects an empty id with ArgumentError', () async {
      final repo = LessonRepository(apiClient: FakeApiClient());

      await expectLater(repo.getLessonById('   '), throwsArgumentError);
    });

    test('failed fetch is not cached and can be retried', () async {
      final api = _FailingOnceApiClient();
      final repo = LessonRepository(apiClient: api);

      await expectLater(repo.getLessons(), throwsException);
      final lessons = await repo.getLessons();

      expect(lessons, hasLength(2));
      expect(api.fetchCount, 2);
    });
  });

  group('service locator', () {
    tearDown(locator.reset);

    test('setupLocator is idempotent and resolves the repository', () {
      setupLocator();
      expect(setupLocator, returnsNormally);
      expect(locator<LessonRepository>(), isA<LessonRepository>());
    });
  });
}

class ControlledApiClient extends ApiClient {
  final completers = <Completer<String>>[];

  @override
  Future<String> getLessonsRaw() {
    final completer = Completer<String>();
    completers.add(completer);
    return completer.future;
  }
}

class _MalformedApiClient extends ApiClient {
  @override
  Future<String> getLessonsRaw() async => '[{"id": "lesson-1"}]';
}

class _FailingOnceApiClient extends FakeApiClient {
  @override
  Future<String> getLessonsRaw() {
    if (fetchCount == 0) {
      fetchCount++;
      return Future.error(Exception('network down'));
    }
    return super.getLessonsRaw();
  }
}
