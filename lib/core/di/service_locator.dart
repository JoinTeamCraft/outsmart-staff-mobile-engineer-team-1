import 'package:get_it/get_it.dart';
import '../network/api_client.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
}