import 'dart:convert';
import 'package:flutter/services.dart';

class ApiClient {
  // Simulates loading data from mock JSON files
  Future<String> getLessonsRaw() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate latency
    return await rootBundle.loadString('assets/mock_data/lessons.json');
  }

  Future<String> getQuizzesRaw() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return await rootBundle.loadString('assets/mock_data/quizzes.json');
  }
}