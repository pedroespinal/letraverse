/// The eight directions a word can be placed in on the puzzle grid.
enum GridDirection { e, w, n, s, se, sw, ne, nw }

extension GridDirectionDelta on GridDirection {
  /// Row delta per step in this direction.
  int get dRow {
    switch (this) {
      case GridDirection.n:
      case GridDirection.ne:
      case GridDirection.nw:
        return -1;
      case GridDirection.s:
      case GridDirection.se:
      case GridDirection.sw:
        return 1;
      case GridDirection.e:
      case GridDirection.w:
        return 0;
    }
  }

  /// Column delta per step in this direction.
  int get dCol {
    switch (this) {
      case GridDirection.e:
      case GridDirection.ne:
      case GridDirection.se:
        return 1;
      case GridDirection.w:
      case GridDirection.nw:
      case GridDirection.sw:
        return -1;
      case GridDirection.n:
      case GridDirection.s:
        return 0;
    }
  }
}
