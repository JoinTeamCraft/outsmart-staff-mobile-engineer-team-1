class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.topic,
    required this.thumbnail,
    required this.content,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        title: json['title'] as String,
        topic: json['topic'] as String,
        thumbnail: json['thumbnail'] as String,
        content: json['content'] as String,
      );

  final String id;
  final String title;
  final String topic;
  final String thumbnail;
  final String content;
}
