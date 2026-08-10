import 'package:hive/hive.dart';

import '../domain/world_generator.dart';

/// Tracks how far the player has progressed. Deliberately stores only the
/// set of completed level indices — never the generated grids themselves —
/// because [WorldGenerator] can always rebuild any level from its index.
class ProgressRepository {
  ProgressRepository(this._box);

  final Box<dynamic> _box;
  static const _completedKey = 'completedLevelIndices';

  Set<int> get completedLevelIndices {
    final raw = _box.get(_completedKey, defaultValue: <int>[]) as List;
    return raw.cast<int>().toSet();
  }

  bool isLevelCompleted(int levelIndex) => completedLevelIndices.contains(levelIndex);

  /// A level is playable once every level before it (in global order) is
  /// completed. Level 0 is always playable.
  bool isLevelUnlocked(int levelIndex) {
    if (levelIndex <= 0) return true;
    return isLevelCompleted(levelIndex - 1);
  }

  bool isWorldUnlocked(int worldIndex) {
    final firstLevel = worldIndex * WorldGenerator.levelsPerWorld;
    return isLevelUnlocked(firstLevel);
  }

  int levelsCompletedInWorld(int worldIndex) {
    final start = worldIndex * WorldGenerator.levelsPerWorld;
    final end = start + WorldGenerator.levelsPerWorld;
    final completed = completedLevelIndices;
    var count = 0;
    for (var i = start; i < end; i++) {
      if (completed.contains(i)) count++;
    }
    return count;
  }

  bool isWorldCompleted(int worldIndex) =>
      levelsCompletedInWorld(worldIndex) == WorldGenerator.levelsPerWorld;

  /// The furthest world the player currently has access to (0-based).
  int get highestUnlockedWorldIndex {
    var world = 0;
    while (isWorldUnlocked(world + 1)) {
      world++;
    }
    return world;
  }

  Future<void> markLevelComplete(int levelIndex) async {
    final updated = completedLevelIndices..add(levelIndex);
    await _box.put(_completedKey, updated.toList(growable: false));
  }

  Future<void> resetAll() async {
    await _box.clear();
  }
}
