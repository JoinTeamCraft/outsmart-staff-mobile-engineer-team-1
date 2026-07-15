import 'dart:convert';

import '../../../core/cache/memory_cache.dart';
import '../../../core/network/api_client.dart';
import '../domain/lesson.dart';

/// Fetches lessons through [ApiClient] and caches the parsed results.
///
/// Repeat calls are served from cache until the TTL expires, concurrent
/// calls share a single in-flight request, and `forceRefresh: true`
/// (pull-to-refresh) bypasses the cache entirely.
class LessonRepository {
  LessonRepository({
    required ApiClient apiClient,
    MemoryCache<String, List<Lesson>>? cache,
  })  : _apiClient = apiClient,
        _cache = cache ?? MemoryCache<String, List<Lesson>>();

  static const _lessonsKey = 'lessons';

  final ApiClient _apiClient;
  final MemoryCache<String, List<Lesson>> _cache;
  Future<List<Lesson>>? _inFlight;

  Future<List<Lesson>> getLessons({bool forceRefresh = false}) {
    if (forceRefresh) {
      _cache.invalidate(_lessonsKey);
    } else {
      final cached = _cache.get(_lessonsKey);
      if (cached != null) return Future.value(cached);

      final pending = _inFlight;
      if (pending != null) return pending;
    }

    final request = _fetchLessons();
    _inFlight = request;
    return request;
  }

  Future<Lesson?> getLessonById(String id, {bool forceRefresh = false}) async {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    final lessons = await getLessons(forceRefresh: forceRefresh);
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }

  Future<List<Lesson>> _fetchLessons() async {
    try {
      final raw = await _apiClient.getLessonsRaw();
      final lessons = (jsonDecode(raw) as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache.set(_lessonsKey, lessons);
      return lessons;
    } finally {
      _inFlight = null;
    }
  }
}
