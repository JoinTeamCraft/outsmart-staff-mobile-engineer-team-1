import 'package:flutter/foundation.dart';

import '../data/lesson_repository.dart';
import '../domain/lesson.dart';

enum FeedStatus { loading, loaded, error }

/// Holds the lesson feed state: the active lesson list plus load/error
/// status. Screens watch this instead of fetching data themselves.
class LessonFeedController extends ChangeNotifier {
  LessonFeedController({required LessonRepository repository})
      : _repository = repository;

  final LessonRepository _repository;

  FeedStatus _status = FeedStatus.loading;
  List<Lesson> _lessons = const [];
  Object? _error;

  FeedStatus get status => _status;
  List<Lesson> get lessons => _lessons;
  Object? get error => _error;

  Future<void> load() => _fetch();

  /// Pull-to-refresh entry point: bypasses the repository cache.
  Future<void> refresh() => _fetch(forceRefresh: true);

  Future<void> _fetch({bool forceRefresh = false}) async {
    if (_lessons.isEmpty) {
      _status = FeedStatus.loading;
      notifyListeners();
    }
    try {
      _lessons = await _repository.getLessons(forceRefresh: forceRefresh);
      _status = FeedStatus.loaded;
      _error = null;
    } on Exception catch (e) {
      _status = FeedStatus.error;
      _error = e;
    }
    notifyListeners();
  }
}
