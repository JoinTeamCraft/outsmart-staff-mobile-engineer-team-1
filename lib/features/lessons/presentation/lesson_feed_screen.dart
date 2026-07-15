import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/state/app_state_manager.dart';
import '../data/lesson_repository.dart';
import '../domain/lesson.dart';
import 'lesson_feed_controller.dart';

class LessonFeedScreen extends StatelessWidget {
  const LessonFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          LessonFeedController(repository: locator<LessonRepository>())..load(),
      child: const _LessonFeedView(),
    );
  }
}

class _LessonFeedView extends StatelessWidget {
  const _LessonFeedView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LessonFeedController>();
    return Scaffold(
      appBar: AppBar(title: const Text('StreakLearn')),
      body: switch (controller.status) {
        FeedStatus.loading => const Center(child: CircularProgressIndicator()),
        FeedStatus.error => _FeedError(
            onRetry: context.read<LessonFeedController>().load,
          ),
        FeedStatus.loaded => RefreshIndicator(
            onRefresh: context.read<LessonFeedController>().refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.lessons.length,
              itemBuilder: (context, index) =>
                  LessonCard(lesson: controller.lessons[index]),
            ),
          ),
      },
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final completed =
        context.watch<AppStateManager>().isLessonCompleted(lesson.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            lesson.thumbnail,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.school),
            ),
          ),
        ),
        title: Text(lesson.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(lesson.topic),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        trailing: completed
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Could not load lessons.'),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
