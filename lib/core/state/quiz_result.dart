class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  double get accuracy => totalQuestions == 0 ? 0 : score / totalQuestions;
  bool get passed => accuracy >= 0.7;
}
