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

    final selected = _selectWords(meta, worldIndex, levelInWorld, langCode);

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

  /// Deals words from a per-category, per-cycle shuffled deck instead of
  /// resampling the category independently every level -- independent
  /// random draws from the same ~60-word category frequently overlap, so
  /// the same handful of words kept resurfacing level after level.
  /// Walking a shared deck forward means every word in the category gets
  /// used once before any of them repeat; a fresh reshuffle only happens
  /// once the deck wraps, or when the player reaches this category again
  /// on a later cycle.
  ///
  /// The deck cursor has to be derived by actually re-walking every prior
  /// level in this world (not just summing their wordCounts): a level
  /// skips over deck words too long for its grid without consuming a
  /// wordCount "slot" for them, so the number of deck *positions* it
  /// passes through is usually more than the number of words it selects.
  /// Using wordCount alone as the increment under-advances the cursor and
  /// reintroduces the very overlap this is meant to avoid.
  List<String> _selectWords(
    WorldMeta meta,
    int worldIndex,
    int levelInWorld,
    String langCode,
  ) {
    // Seeded via plain arithmetic on cycle/posInCycle, deliberately *not*
    // categoryId.hashCode or Object.hash(...): both are randomized
    // per-isolate by the Dart VM (hash-flood mitigation applies to
    // Object.hash's int overloads too, not just String.hashCode), so
    // either would reshuffle the deck differently on every app launch,
    // breaking the "same seed in, same puzzle out" guarantee this whole
    // engine exists to provide. Same trick _shuffledCategoriesForCycle
    // already uses above.
    final deck = [..._wordBanks.wordsFor(meta.categoryId, langCode)]
      ..shuffle(Random(meta.cycle * 104729 + meta.posInCycle));
    if (deck.isEmpty) return const [];

    var cursor = 0;
    var selected = const <String>[];
    for (var level = 0; level <= levelInWorld; level++) {
      final difficulty = difficultyFor(worldIndex, level);
      final picked = <String>[];
      var step = 0;
      for (; step < deck.length && picked.length < difficulty.wordCount; step++) {
        final word = deck[(cursor + step) % deck.length];
        if (word.length <= difficulty.gridSize) picked.add(word);
      }
      cursor = (cursor + step) % deck.length;
      selected = picked;
    }

    if (selected.isEmpty) {
      // Nothing in the category fits this grid size -- fall back to the
      // shortest word so the level can still be generated.
      selected = [deck.reduce((a, b) => a.length <= b.length ? a : b)];
    }
    return selected;
  }
}
