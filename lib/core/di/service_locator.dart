import 'package:get_it/get_it.dart';
import 'package:streaklearn/features/lessons/data/lesson_repository.dart';

import '../network/api_client.dart';
import '../state/app_state_manager.dart';

final GetIt locator = GetIt.instance;

/// Registers app-wide singletons. Idempotent: repeat calls (hot restart,
/// test setup alongside main) keep the first registration. Tests that need
/// a fresh graph (e.g. an AppStateManager with a custom clock) must call
/// `locator.reset()` before registering their own instances.
void setupLocator() {
  if (!locator.isRegistered<ApiClient>()) {
    locator.registerLazySingleton<ApiClient>(() => ApiClient());
  }
  if (!locator.isRegistered<AppStateManager>()) {
    locator.registerLazySingleton<AppStateManager>(
      () => AppStateManager(),
      dispose: (manager) => manager.dispose(),
    );
  }
  if (!locator.isRegistered<LessonRepository>()) {
    locator.registerLazySingleton<LessonRepository>(
      () => LessonRepository(apiClient: locator<ApiClient>()),
    );
  }
}
