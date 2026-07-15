class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.topic,
    required this.thumbnail,
    required this.content,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    String field(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('Lesson JSON has a missing or invalid "$key"');
      }
      return value;
    }

    return Lesson(
      id: field('id'),
      title: field('title'),
      topic: field('topic'),
      thumbnail: field('thumbnail'),
      content: field('content'),
    );
  }

  final String id;
  final String title;
  final String topic;
  final String thumbnail;
  final String content;
}
