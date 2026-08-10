import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:letraverse/core/providers.dart';
import 'package:letraverse/core/sound_service.dart';
import 'package:letraverse/data/progress_repository.dart';
import 'package:letraverse/data/stats_repository.dart';
import 'package:letraverse/domain/models/puzzle.dart';
import 'package:letraverse/domain/word_bank_repository.dart';
import 'package:letraverse/domain/world_generator.dart';
import 'package:letraverse/features/play/play_controller.dart';

// The real SoundService constructs an AudioPlayer, which needs a platform
// channel that only exists under testWidgets()/a real app run. These are
// plain test()s exercising PlayController's state machine, so swap in a
// no-op that satisfies the same public surface without touching audio.
class _NoopSoundService implements SoundService {
  @override
  Future<void> wordFound() async {}

  @override
  Future<void> levelComplete() async {}

  @override
  void dispose() {}
}

void main() {
  late final WordBankRepository wordBanks;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    wordBanks = WordBankRepository();
    await wordBanks.load();
  });

  late ProviderContainer container;
  late ProgressRepository progress;
  late StatsRepository stats;

  // [completedLevels] pre-populates progress *before* the controller reads
  // it in its constructor, so tests can start mid-world or mid-game instead
  // of always from level 0.
  Future<void> buildContainer({Set<int> completedLevels = const {}}) async {
    final progressBox = await Hive.openBox<dynamic>('progress', bytes: Uint8List(0));
    final statsBox = await Hive.openBox<dynamic>('stats', bytes: Uint8List(0));
    progress = ProgressRepository(progressBox);
    for (final level in completedLevels) {
      await progress.markLevelComplete(level);
    }
    stats = StatsRepository(statsBox);

    container = ProviderContainer(
      overrides: [
        wordBankRepositoryProvider.overrideWithValue(wordBanks),
        progressRepositoryProvider.overrideWithValue(progress),
        statsRepositoryProvider.overrideWithValue(stats),
        soundServiceProvider.overrideWithValue(_NoopSoundService()),
      ],
    );
    // Autodispose providers are torn down once their last listener drops;
    // container.read() alone doesn't hold one open. This keeps the
    // controller (and its internal Timer) alive for the test, and lets
    // container.dispose() in tearDown cancel that timer cleanly.
    container.listen(playControllerProvider, (_, _) {});
    addTearDown(container.dispose);
  }

  tearDown(() async {
    await Hive.close();
  });

  PlayController controller() => container.read(playControllerProvider.notifier);
  PlayState state() => container.read(playControllerProvider);

  test('starts at world 0, level 0 with no prior progress, puzzle unloaded', () async {
    await buildContainer();

    expect(state().worldIndex, 0);
    expect(state().levelInWorld, 0);
    expect(state().puzzle, isNull);
  });

  test('resumes at the first uncompleted level, not level 0', () async {
    // Levels 0..8 done (world 0 fully done, plus level 8 = world 1 level 0).
    await buildContainer(completedLevels: {0, 1, 2, 3, 4, 5, 6, 7, 8});

    expect(state().worldIndex, 1);
    expect(state().levelInWorld, 1);
  });

  test('loadCurrentPuzzle populates a puzzle matching the current world/level', () async {
    await buildContainer();

    controller().loadCurrentPuzzle('en');

    final puzzle = state().puzzle;
    expect(puzzle, isNotNull);
    expect(puzzle!.worldIndex, 0);
    expect(puzzle.levelInWorld, 0);
    expect(state().foundWords, isEmpty);
    expect(state().isComplete, isFalse);
  });

  test('submitSelection finds a word selected forward or reversed', () async {
    await buildContainer();
    controller().loadCurrentPuzzle('en');
    final puzzle = state().puzzle!;
    final forward = puzzle.placedWords.first;

    controller().updateSelection(forward.cells);
    controller().submitSelection();
    expect(state().foundWords, contains(forward.word));

    if (puzzle.placedWords.length > 1) {
      final reversedTarget = puzzle.placedWords[1];
      controller().updateSelection(reversedTarget.cells.reversed.toList());
      controller().submitSelection();
      expect(state().foundWords, contains(reversedTarget.word));
    }
  });

  test('submitSelection ignores a selection matching no word', () async {
    await buildContainer();
    controller().loadCurrentPuzzle('en');

    // A single-cell selection can never equal a placed word's cell
    // sequence, since every word bank entry is at least 2 letters long.
    controller().updateSelection([(0, 0)]);
    controller().submitSelection();

    expect(state().foundWords, isEmpty);
    expect(state().isComplete, isFalse);
  });

  test('finding every word completes the level and records progress + stats', () async {
    await buildContainer();
    controller().loadCurrentPuzzle('en');
    final Puzzle puzzle = state().puzzle!;

    for (final placed in puzzle.placedWords) {
      controller().updateSelection(placed.cells);
      controller().submitSelection();
    }

    // The last submitSelection() fires _completeLevel() without awaiting
    // it (fire-and-forget from the UI's perspective), so give its pending
    // Hive writes a chance to finish before asserting / tearing down.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(state().isComplete, isTrue);
    expect(state().foundWords.length, puzzle.words.length);
    expect(progress.isLevelCompleted(puzzle.levelIndex), isTrue);
    expect(stats.totalLevelsCompleted, 1);
    expect(stats.totalWordsFound, puzzle.words.length);
  });

  test('goToNextLevel advances within the same world and resets round state', () async {
    await buildContainer();
    controller().loadCurrentPuzzle('en');
    controller().updateSelection(state().puzzle!.placedWords.first.cells);
    controller().submitSelection();

    controller().goToNextLevel('en');

    expect(state().worldIndex, 0);
    expect(state().levelInWorld, 1);
    expect(state().foundWords, isEmpty);
    expect(state().isComplete, isFalse);
    expect(state().justUnlockedWorldIndex, isNull);
  });

  test('goToNextLevel wraps into a new world after the last level and flags the unlock', () async {
    await buildContainer(completedLevels: {0, 1, 2, 3, 4, 5, 6});
    expect(state().worldIndex, 0);
    expect(state().levelInWorld, WorldGenerator.levelsPerWorld - 1);

    controller().goToNextLevel('en');

    expect(state().worldIndex, 1);
    expect(state().levelInWorld, 0);
    expect(state().justUnlockedWorldIndex, 1);
  });

  test('jumpToLevel loads directly into an arbitrary world/level', () async {
    await buildContainer();

    controller().jumpToLevel(worldIndex: 2, levelInWorld: 3, langCode: 'en');

    expect(state().worldIndex, 2);
    expect(state().levelInWorld, 3);
    expect(state().puzzle, isNotNull);
    expect(state().puzzle!.worldIndex, 2);
    expect(state().puzzle!.levelInWorld, 3);
  });
}
