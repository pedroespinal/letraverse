import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/providers.dart';
import '../../core/sound_service.dart';
import '../../domain/models/puzzle.dart';
import '../../domain/world_generator.dart';
import 'selection_path.dart';

class PlayState {
  const PlayState({
    required this.worldIndex,
    required this.levelInWorld,
    this.puzzle,
    this.foundWords = const {},
    this.selection = const [],
    this.elapsed = Duration.zero,
    this.isComplete = false,
    this.justUnlockedWorldIndex,
  });

  final int worldIndex;
  final int levelInWorld;
  final Puzzle? puzzle;
  final Set<String> foundWords;
  final List<(int, int)> selection;
  final Duration elapsed;
  final bool isComplete;

  /// Set for one frame right after crossing into a brand-new world, so the
  /// UI can show the "new world unlocked" moment once.
  final int? justUnlockedWorldIndex;

  PlayState copyWith({
    int? worldIndex,
    int? levelInWorld,
    Puzzle? puzzle,
    Set<String>? foundWords,
    List<(int, int)>? selection,
    Duration? elapsed,
    bool? isComplete,
    int? justUnlockedWorldIndex,
    bool clearUnlockFlag = false,
  }) {
    return PlayState(
      worldIndex: worldIndex ?? this.worldIndex,
      levelInWorld: levelInWorld ?? this.levelInWorld,
      puzzle: puzzle ?? this.puzzle,
      foundWords: foundWords ?? this.foundWords,
      selection: selection ?? this.selection,
      elapsed: elapsed ?? this.elapsed,
      isComplete: isComplete ?? this.isComplete,
      justUnlockedWorldIndex:
          clearUnlockFlag ? null : (justUnlockedWorldIndex ?? this.justUnlockedWorldIndex),
    );
  }
}

class PlayController extends StateNotifier<PlayState> {
  PlayController(this._ref) : super(_initial(_ref));

  final Ref _ref;
  Timer? _timer;

  static PlayState _initial(Ref ref) {
    final progress = ref.read(progressRepositoryProvider);
    final completed = progress.completedLevelIndices;
    var levelIndex = 0;
    while (completed.contains(levelIndex)) {
      levelIndex++;
    }
    final worldIndex = levelIndex ~/ WorldGenerator.levelsPerWorld;
    final levelInWorld = levelIndex % WorldGenerator.levelsPerWorld;
    return PlayState(worldIndex: worldIndex, levelInWorld: levelInWorld);
  }

  void loadCurrentPuzzle(String langCode) {
    final generator = _ref.read(worldGeneratorProvider);
    final puzzle = generator.buildPuzzle(
      worldIndex: state.worldIndex,
      levelInWorld: state.levelInWorld,
      langCode: langCode,
    );
    // Note: justUnlockedWorldIndex is intentionally left untouched here so a
    // flag set by goToNextLevel() right before this call survives long
    // enough for the UI to show the "new world" banner and clear it itself.
    state = state.copyWith(
      puzzle: puzzle,
      foundWords: const {},
      selection: const [],
      elapsed: Duration.zero,
      isComplete: false,
    );
    _startTimer();
  }

  void acknowledgeWorldUnlock() {
    state = state.copyWith(clearUnlockFlag: true);
  }

  void updateSelection(List<(int, int)> path) {
    if (state.isComplete) return;
    state = state.copyWith(selection: path);
  }

  void submitSelection() {
    final puzzle = state.puzzle;
    if (puzzle == null || state.selection.isEmpty || state.isComplete) return;
    for (final placed in puzzle.placedWords) {
      if (state.foundWords.contains(placed.word)) continue;
      final cells = placed.cells;
      if (sameCellSequence(state.selection, cells) ||
          sameCellSequence(state.selection, cells.reversed.toList())) {
        final updatedFound = {...state.foundWords, placed.word};
        state = state.copyWith(foundWords: updatedFound, selection: const []);
        _ref.read(soundServiceProvider).wordFound();
        _ref.read(statsRepositoryProvider).recordWordFound();
        _ref.read(statsRevisionProvider.notifier).state++;
        if (updatedFound.length == puzzle.words.length) {
          _completeLevel();
        }
        return;
      }
    }
    state = state.copyWith(selection: const []);
  }

  Future<void> _completeLevel() async {
    _timer?.cancel();
    final puzzle = state.puzzle;
    if (puzzle == null) return;
    final progress = _ref.read(progressRepositoryProvider);
    await progress.markLevelComplete(puzzle.levelIndex);
    _ref.read(progressRevisionProvider.notifier).state++;
    await _ref.read(statsRepositoryProvider).recordLevelCompleted(state.elapsed);
    _ref.read(statsRevisionProvider.notifier).state++;
    _ref.read(soundServiceProvider).levelComplete();
    state = state.copyWith(isComplete: true);
  }

  void goToNextLevel(String langCode) {
    var nextLevelInWorld = state.levelInWorld + 1;
    var nextWorldIndex = state.worldIndex;
    int? unlockedWorld;
    if (nextLevelInWorld >= WorldGenerator.levelsPerWorld) {
      nextLevelInWorld = 0;
      nextWorldIndex++;
      unlockedWorld = nextWorldIndex;
    }
    state = PlayState(
      worldIndex: nextWorldIndex,
      levelInWorld: nextLevelInWorld,
      justUnlockedWorldIndex: unlockedWorld,
    );
    loadCurrentPuzzle(langCode);
  }

  void jumpToLevel({required int worldIndex, required int levelInWorld, required String langCode}) {
    state = PlayState(worldIndex: worldIndex, levelInWorld: levelInWorld);
    loadCurrentPuzzle(langCode);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isComplete) {
        state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final playControllerProvider = StateNotifierProvider.autoDispose<PlayController, PlayState>(
  (ref) => PlayController(ref),
);
