# State Management Contract

This document defines how every track reads and writes shared app state.
The state layer is `AppStateManager` (`lib/core/state/app_state_manager.dart`),
a `ChangeNotifier` registered as a lazy singleton in the service locator and
exposed to the widget tree through `provider` in `main.dart`.

Do not hold feature-level copies of this state. Read it from the manager,
write it through the methods below, and react to one-shot side effects via
the `events` stream.

## Getting the manager

```dart
// Outside the widget tree (repositories, controllers, tests):
final state = locator<AppStateManager>();

// Inside widgets — rebuilds on every state change:
final state = context.watch<AppStateManager>();

// Inside callbacks — no rebuild subscription:
final state = context.read<AppStateManager>();
```

## Public properties (read)

| Property | Type | Meaning |
| --- | --- | --- |
| `completedLessonIds` | `Set<String>` | Unmodifiable set of completed lesson ids |
| `lastQuizResult` | `QuizResult?` | Most recent quiz result, `null` before the first quiz |
| `streakCount` | `int` | Consecutive active days, `0` before any activity |
| `lastActivityDate` | `DateTime?` | Date (midnight-truncated) of the last recorded activity |
| `events` | `Stream<AppStateEvent>` | Broadcast stream of one-shot events |

Plus one query method:

```dart
bool isLessonCompleted(String lessonId);
```

## Public methods (write)

```dart
void completeLesson(String lessonId);
void completeQuiz({
  required String quizId,
  required int score,
  required int totalQuestions,
});
void resetState();
```

- `completeLesson` is idempotent: re-completing a lesson is a no-op.
- Both completion methods record daily activity, which drives the streak:
  first activity sets it to 1, next-day activity increments it, a gap of
  more than one day resets it to 1, same-day repeats don't change it.
- `resetState` clears everything (Settings > reset progress).

## Events

Every event extends the sealed class `AppStateEvent`:

| Event | Payload | Emitted when |
| --- | --- | --- |
| `LessonCompletedEvent` | `lessonId` | A lesson is completed for the first time |
| `QuizCompletedEvent` | `result` (`QuizResult`) | A quiz is completed |
| `StreakChangedEvent` | `previous`, `current` | The streak count changes |

`QuizResult` fields: `quizId`, `score`, `totalQuestions`, `completedAt`,
plus derived `accuracy` (0.0–1.0) and `passed` (accuracy >= 0.7).

## Examples

### Reading state in a widget (Track B / D)

```dart
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateManager>();
    return Text('${state.streakCount} day streak');
  }
}
```

### Triggering a quiz completed state (Track C)

```dart
void onQuizFinished(BuildContext context) {
  context.read<AppStateManager>().completeQuiz(
        quizId: 'quiz_flutter_basics',
        score: 4,
        totalQuestions: 5,
      );
}
```

### Marking a lesson complete (Track A / B)

```dart
void onLessonFinished(String lessonId) {
  locator<AppStateManager>().completeLesson(lessonId);
}
```

### Listening for one-shot events (Track D streak animation)

```dart
late final StreamSubscription<AppStateEvent> _sub;

@override
void initState() {
  super.initState();
  _sub = locator<AppStateManager>().events.listen((event) {
    if (event is StreakChangedEvent && event.current > event.previous) {
      // play streak animation
    }
  });
}

@override
void dispose() {
  _sub.cancel();
  super.dispose();
}
```

## Testing

Inject a fixed clock to make streak logic deterministic:

```dart
final state = AppStateManager(clock: () => DateTime(2026, 7, 14));
```

The examples above are kept compiling in
`test/state_contract_examples_test.dart` — update that test whenever this
contract changes.
