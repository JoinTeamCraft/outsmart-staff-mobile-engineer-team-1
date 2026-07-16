import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state_manager.dart';

/// Overlays a short-lived celebration banner whenever the state layer
/// reports real progression: a streak increment or a passed quiz.
///
/// Animations are driven by one-shot [AppStateManager.events] rather than
/// derived from rebuilt state, so rebuilds and hot reloads never re-trigger
/// a celebration: hot reload preserves this state object and its existing
/// stream subscription, and no new events are emitted by reassembly.
class StreakCelebrationListener extends StatefulWidget {
  const StreakCelebrationListener({
    required this.child,
    this.stateManager,
    this.displayDuration = const Duration(seconds: 2),
    super.key,
  });

  final Widget child;

  /// Resolved from the widget tree (`context.read`) when null;
  /// injectable for tests.
  final AppStateManager? stateManager;
  final Duration displayDuration;

  @override
  State<StreakCelebrationListener> createState() =>
      _StreakCelebrationListenerState();
}

class _StreakCelebrationListenerState extends State<StreakCelebrationListener> {
  StreamSubscription<AppStateEvent>? _subscription;
  Timer? _dismissTimer;
  String? _message;

  @override
  void initState() {
    super.initState();
    final manager = widget.stateManager ?? context.read<AppStateManager>();
    _subscription = manager.events.listen(_handleEvent);
  }

  void _handleEvent(AppStateEvent event) {
    final message = switch (event) {
      StreakChangedEvent(:final previous, :final current)
          when current > previous =>
        '$current day streak!',
      QuizCompletedEvent(:final result) when result.passed =>
        'Quiz passed ${result.score}/${result.totalQuestions}!',
      _ => null,
    };
    if (message == null) return;

    _dismissTimer?.cancel();
    setState(() => _message = message);
    _dismissTimer = Timer(widget.displayDuration, () {
      if (!mounted) return;
      setState(() => _message = null);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        widget.child,
        if (_message != null)
          _CelebrationBanner(key: ValueKey(_message), message: _message!),
      ],
    );
  }
}

class _CelebrationBanner extends StatelessWidget {
  const _CelebrationBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: value, child: child),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
