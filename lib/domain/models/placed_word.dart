import 'grid_direction.dart';

/// A word placed on the puzzle grid, anchored at [startRow]/[startCol]
/// and extending one cell per letter along [direction].
class PlacedWord {
  const PlacedWord({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
  });

  final String word;
  final int startRow;
  final int startCol;
  final GridDirection direction;

  /// The (row, col) of every cell this word occupies, in order.
  List<(int, int)> get cells => List.generate(word.length, (i) {
        return (startRow + direction.dRow * i, startCol + direction.dCol * i);
      });

  (int, int) get endCell {
    final last = word.length - 1;
    return (startRow + direction.dRow * last, startCol + direction.dCol * last);
  }
}
