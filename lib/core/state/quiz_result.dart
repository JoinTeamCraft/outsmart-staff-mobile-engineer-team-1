class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  })  : assert(totalQuestions > 0, 'totalQuestions must be greater than zero'),
        assert(score >= 0 && score <= totalQuestions,
            'score must be between 0 and totalQuestions');

  static const double passThreshold = 0.7;

  final String quizId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  // Guarded despite the asserts so release builds never divide by zero.
  double get accuracy => totalQuestions == 0 ? 0 : score / totalQuestions;
  bool get passed => accuracy >= passThreshold;
}
