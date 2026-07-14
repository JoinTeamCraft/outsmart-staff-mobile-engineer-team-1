import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up service locator
  setupLocator();
  
  runApp(const StreakLearnApp());
}