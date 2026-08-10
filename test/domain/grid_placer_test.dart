import 'package:flutter_test/flutter_test.dart';
import 'package:hiddenwords/domain/grid_placer.dart';
import 'package:hiddenwords/domain/models/grid_direction.dart';

void main() {
  const placer = GridPlacer();

  test('places every requested word and every cell it occupies matches the word letters', () {
    final words = ['GATO', 'PERRO', 'LEON', 'TIGRE', 'OSO', 'LOBO'];
    final result = placer.generate(
      size: 10,
      words: words,
      allowDiagonal: true,
      allowReverse: true,
      seed: 42,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );

    expect(result.placedWords.map((p) => p.word).toSet(), words.toSet());

    for (final placed in result.placedWords) {
      for (var i = 0; i < placed.word.length; i++) {
        final (r, c) = placed.cells[i];
        expect(r, inInclusiveRange(0, result.size - 1));
        expect(c, inInclusiveRange(0, result.size - 1));
        expect(result.letters[r][c], placed.word[i]);
      }
    }
  });

  test('leaves no null/empty cells after filling gaps', () {
    final result = placer.generate(
      size: 8,
      words: ['SOL', 'LUNA', 'MAR'],
      allowDiagonal: false,
      allowReverse: false,
      seed: 7,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    for (final row in result.letters) {
      for (final cell in row) {
        expect(cell, isNotEmpty);
        expect(cell.length, 1);
      }
    }
  });

  test('is deterministic for identical inputs', () {
    final a = placer.generate(
      size: 12,
      words: ['ROJO', 'AZUL', 'VERDE', 'AMARILLO', 'MORADO'],
      allowDiagonal: true,
      allowReverse: false,
      seed: 999,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    final b = placer.generate(
      size: 12,
      words: ['ROJO', 'AZUL', 'VERDE', 'AMARILLO', 'MORADO'],
      allowDiagonal: true,
      allowReverse: false,
      seed: 999,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    expect(a.letters, b.letters);
    expect(a.placedWords.length, b.placedWords.length);
  });

  test('only uses allowed directions (no diagonal/reverse when disabled)', () {
    final result = placer.generate(
      size: 10,
      words: ['CASA', 'MESA', 'SILLA', 'LIBRO', 'PUERTA'],
      allowDiagonal: false,
      allowReverse: false,
      seed: 5,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    for (final placed in result.placedWords) {
      expect(placed.direction.dRow == 0 || placed.direction.dCol == 0, isTrue);
      expect(placed.direction.dRow, isNot(-1));
      expect(placed.direction.dCol, isNot(-1));
    }
  });

  test('grows the grid instead of failing when words cannot fit at the requested size', () {
    final longWords = ['INTERNACIONALIZACION', 'CONSTITUCIONALIDAD', 'ESTABLECIMIENTOS'];
    final result = placer.generate(
      size: 8,
      words: longWords,
      allowDiagonal: true,
      allowReverse: true,
      seed: 3,
      fillerAlphabet: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    );
    expect(result.size, greaterThanOrEqualTo(20)); // longest word here is 20 letters
    expect(result.placedWords.length, longWords.length);
  });
}
