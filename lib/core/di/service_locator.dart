import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../state/app_state_manager.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  locator.registerLazySingleton<AppStateManager>(() => AppStateManager());
}