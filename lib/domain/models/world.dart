/// Metadata for one infinite-mode "world": a themed chapter of
/// [levelsPerWorld] puzzles sharing a category, with difficulty ramping
/// both within the world and across worlds (cycles).
class WorldMeta {
  const WorldMeta({
    required this.index,
    required this.categoryId,
    required this.cycle,
    required this.posInCycle,
  });

  final int index;
  final String categoryId;

  /// How many times we've looped through every category (0 = first pass).
  final int cycle;

  /// Position of this world's category within the current cycle's shuffled order.
  final int posInCycle;
}

class WorldDifficulty {
  const WorldDifficulty({
    required this.gridSize,
    required this.wordCount,
    required this.allowDiagonal,
    required this.allowReverse,
  });

  final int gridSize;
  final int wordCount;
  final bool allowDiagonal;
  final bool allowReverse;
}
