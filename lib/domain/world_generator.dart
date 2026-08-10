import 'dart:math';

import 'grid_placer.dart';
import 'models/puzzle.dart';
import 'models/world.dart';
import 'word_bank_repository.dart';

const String fillerAlphabetEs = 'ABCDEFGHIJKLMNOPQRSTUVWXYZÑ';
const String fillerAlphabetEn = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/// The "infinite worlds" engine: given only a world/level index it
/// deterministically reconstructs the same puzzle every time (same seed in,
/// same grid out), so the app never needs to store generated grids — only
/// how far the player has progressed. This is what lets new worlds appear
/// automatically forever without a network call or a generation cost.
class WorldGenerator {
  WorldGenerator(this._wordBanks);

  final WordBankRepository _wordBanks;

  static const int levelsPerWorld = 8;

  int globalLevelIndex(int worldIndex, int levelInWorld) =>
      worldIndex * levelsPerWorld + levelInWorld;

  WorldMeta worldMetaFor(int worldIndex) {
    final categories = _wordBanks.categoryIds;
    final categoryCount = categories.length;
    final cycle = worldIndex ~/ categoryCount;
    final posInCycle = worldIndex % categoryCount;
    final order = _shuffledCategoriesForCycle(cycle);
    return WorldMeta(
      index: worldIndex,
      categoryId: order[posInCycle],
      cycle: cycle,
      posInCycle: posInCycle,
    );
  }

  List<String> _shuffledCategoriesForCycle(int cycle) {
    final ids = [..._wordBanks.categoryIds];
    final rng = Random(cycle == 0 ? 1 : cycle * 104729);
    ids.shuffle(rng);
    return ids;
  }

  WorldDifficulty difficultyFor(int worldIndex, int levelInWorld) {
    final cycle = worldIndex ~/ _wordBanks.categoryIds.length;
    final gridSize = _clampInt(8 + cycle * 2 + (levelInWorld ~/ 3), 8, 20);
    final wordCount = _clampInt(6 + cycle * 2 + (levelInWorld ~/ 2), 6, 22);
    return WorldDifficulty(
      gridSize: gridSize,
      wordCount: wordCount,
      allowDiagonal: worldIndex >= 1,
      allowReverse: worldIndex >= 3,
    );
  }

  /// Builds the puzzle for (worldIndex, levelInWorld) in [langCode] ('es'/'en').
  /// Pure function of its inputs plus the bundled word banks: same
  /// arguments always produce the same grid.
  Puzzle buildPuzzle({
    required int worldIndex,
    required int levelInWorld,
    required String langCode,
  }) {
    final meta = worldMetaFor(worldIndex);
    final difficulty = difficultyFor(worldIndex, levelInWorld);
    final levelIndex = globalLevelIndex(worldIndex, levelInWorld);

    final allWords = _wordBanks.wordsFor(meta.categoryId, langCode);
    final eligible = allWords.where((w) => w.length <= difficulty.gridSize).toList()
      ..shuffle(Random(levelIndex));
    final targetCount = min(difficulty.wordCount, eligible.length);
    final selected = eligible.take(max(targetCount, 1)).toList();

    final filler = langCode == 'es' ? fillerAlphabetEs : fillerAlphabetEn;
    final placement = const GridPlacer().generate(
      size: difficulty.gridSize,
      words: selected,
      allowDiagonal: difficulty.allowDiagonal,
      allowReverse: difficulty.allowReverse,
      seed: levelIndex,
      fillerAlphabet: filler,
    );

    return Puzzle(
      worldIndex: worldIndex,
      levelIndex: levelIndex,
      levelInWorld: levelInWorld,
      categoryId: meta.categoryId,
      size: placement.size,
      letters: placement.letters,
      placedWords: placement.placedWords,
    );
  }

  int _clampInt(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
