import 'package:get_it/get_it.dart';
import 'package:streaklearn/features/lessons/data/lesson_repository.dart';

import '../network/api_client.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(() => ApiClient());
  }
  if (!locator.isRegistered<LessonRepository>()) {
    locator.registerLazySingleton<LessonRepository>(
      () => LessonRepository(apiClient: locator<ApiClient>()),
    );
  }
}
