import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/di/service_locator.dart';
import 'core/state/app_state_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  assert(
    locator.isRegistered<AppStateManager>(),
    'setupLocator() must register AppStateManager before the app is built',
  );

  runApp(
    ChangeNotifierProvider.value(
      value: locator<AppStateManager>(),
      child: const StreakLearnApp(),
    ),
  );
}
