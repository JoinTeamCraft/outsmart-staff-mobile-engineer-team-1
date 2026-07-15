import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../state/app_state_manager.dart';

final GetIt locator = GetIt.instance;

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
}