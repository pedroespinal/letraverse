import 'dart:math';

import 'models/grid_direction.dart';
import 'models/placed_word.dart';

class GridPlacementResult {
  const GridPlacementResult({
    required this.letters,
    required this.placedWords,
    required this.size,
  });

  final List<List<String>> letters;
  final List<PlacedWord> placedWords;
  final int size;
}

class _PlacementAttempt {
  _PlacementAttempt(this.grid, this.placedWords);
  final List<List<String?>> grid;
  final List<PlacedWord> placedWords;
}

/// Places words on a square letter grid with backtracking, guaranteeing every
/// word ends up placed (growing the grid or reseeding if a layout gets
/// stuck) so every generated puzzle is solvable by construction.
class GridPlacer {
  const GridPlacer();

  static const int _maxGrowthAttempts = 12;
  static const int _attemptsPerWord = 300;

  List<GridDirection> _directionsFor({
    required bool allowDiagonal,
    required bool allowReverse,
  }) {
    final dirs = <GridDirection>[GridDirection.e, GridDirection.s];
    if (allowReverse) dirs.addAll([GridDirection.w, GridDirection.n]);
    if (allowDiagonal) dirs.addAll([GridDirection.se, GridDirection.nw]);
    if (allowDiagonal && allowReverse) {
      dirs.addAll([GridDirection.sw, GridDirection.ne]);
    }
    return dirs;
  }

  GridPlacementResult generate({
    required int size,
    required List<String> words,
    required bool allowDiagonal,
    required bool allowReverse,
    required int seed,
    required String fillerAlphabet,
  }) {
    // No point attempting placement below the longest word's length: skip
    // straight to a size that can possibly fit every word.
    final longest = words.isEmpty ? 0 : words.map((w) => w.length).reduce(max);
    var currentSize = size < longest ? longest : size;
    var attemptSeed = seed;
    for (var growth = 0; growth <= _maxGrowthAttempts; growth++) {
      final attempt = _tryPlaceAll(
        size: currentSize,
        words: words,
        allowDiagonal: allowDiagonal,
        allowReverse: allowReverse,
        seed: attemptSeed,
      );
      if (attempt != null) {
        final letters = _fillGaps(attempt.grid, seed, fillerAlphabet);
        return GridPlacementResult(
          letters: letters,
          placedWords: attempt.placedWords,
          size: currentSize,
        );
      }
      attemptSeed = attemptSeed * 31 + growth + 7;
      currentSize += 1;
    }
    throw StateError(
      'No se pudieron colocar todas las palabras tras $_maxGrowthAttempts '
      'intentos de crecimiento de grilla.',
    );
  }

  _PlacementAttempt? _tryPlaceAll({
    required int size,
    required List<String> words,
    required bool allowDiagonal,
    required bool allowReverse,
    required int seed,
  }) {
    final rng = Random(seed);
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final directions = _directionsFor(
      allowDiagonal: allowDiagonal,
      allowReverse: allowReverse,
    );
    final ordered = [...words]..sort((a, b) => b.length.compareTo(a.length));
    final placed = <PlacedWord>[];

    for (final word in ordered) {
      if (word.length > size) return null;
      var placedThisWord = false;
      for (var attempt = 0; attempt < _attemptsPerWord && !placedThisWord; attempt++) {
        final direction = directions[rng.nextInt(directions.length)];
        final startRow = rng.nextInt(size);
        final startCol = rng.nextInt(size);
        final endRow = startRow + direction.dRow * (word.length - 1);
        final endCol = startCol + direction.dCol * (word.length - 1);
        if (endRow < 0 || endRow >= size || endCol < 0 || endCol >= size) {
          continue;
        }
        var fits = true;
        for (var i = 0; i < word.length; i++) {
          final r = startRow + direction.dRow * i;
          final c = startCol + direction.dCol * i;
          final existing = grid[r][c];
          if (existing != null && existing != word[i]) {
            fits = false;
            break;
          }
        }
        if (!fits) continue;
        for (var i = 0; i < word.length; i++) {
          final r = startRow + direction.dRow * i;
          final c = startCol + direction.dCol * i;
          grid[r][c] = word[i];
        }
        placed.add(PlacedWord(
          word: word,
          startRow: startRow,
          startCol: startCol,
          direction: direction,
        ));
        placedThisWord = true;
      }
      if (!placedThisWord) return null;
    }
    return _PlacementAttempt(grid, placed);
  }

  List<List<String>> _fillGaps(
    List<List<String?>> grid,
    int seed,
    String fillerAlphabet,
  ) {
    final rng = Random(seed ^ 0x5BD1E995);
    return grid
        .map((row) => row
            .map((cell) => cell ?? fillerAlphabet[rng.nextInt(fillerAlphabet.length)])
            .toList(growable: false))
        .toList(growable: false);
  }
}
