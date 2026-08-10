import 'placed_word.dart';

/// A fully generated, solvable word-search puzzle.
class Puzzle {
  const Puzzle({
    required this.worldIndex,
    required this.levelIndex,
    required this.levelInWorld,
    required this.categoryId,
    required this.size,
    required this.letters,
    required this.placedWords,
  });

  final int worldIndex;
  final int levelIndex;
  final int levelInWorld;
  final String categoryId;
  final int size;

  /// Row-major grid of single-character strings, size x size.
  final List<List<String>> letters;

  final List<PlacedWord> placedWords;

  List<String> get words => placedWords.map((p) => p.word).toList(growable: false);
}
