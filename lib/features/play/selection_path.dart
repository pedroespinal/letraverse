import 'dart:math' as math;

/// Snaps a freehand drag from [start] to [end] onto the nearest valid
/// word-search line (horizontal, vertical, or perfect diagonal) so users
/// don't need pixel-perfect drags to select a word.
List<(int, int)> computeSelectionPath((int, int) start, (int, int) end) {
  final dr = end.$1 - start.$1;
  final dc = end.$2 - start.$2;
  if (dr == 0 && dc == 0) return [start];

  final stepR = dr == 0 ? 0 : (dr > 0 ? 1 : -1);
  final stepC = dc == 0 ? 0 : (dc > 0 ? 1 : -1);
  final isDiagonal = dr.abs() == dc.abs();
  final isStraight = dr == 0 || dc == 0;

  if (isDiagonal || isStraight) {
    final length = math.max(dr.abs(), dc.abs());
    return List.generate(length + 1, (i) => (start.$1 + stepR * i, start.$2 + stepC * i));
  }

  // Off-axis drag: snap to whichever axis moved further.
  if (dr.abs() > dc.abs()) {
    return List.generate(dr.abs() + 1, (i) => (start.$1 + stepR * i, start.$2));
  }
  return List.generate(dc.abs() + 1, (i) => (start.$1, start.$2 + stepC * i));
}

bool sameCellSequence(List<(int, int)> a, List<(int, int)> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
