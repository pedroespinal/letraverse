import 'package:flutter_test/flutter_test.dart';
import 'package:letraverse/domain/models/world.dart';
import 'package:letraverse/domain/word_bank_repository.dart';
import 'package:letraverse/domain/world_generator.dart';

void main() {
  late WordBankRepository repo;
  late WorldGenerator generator;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repo = WordBankRepository();
    await repo.load();
    generator = WorldGenerator(repo);
  });

  test('word bank loads matching es/en categories', () {
    expect(repo.categoryIds, isNotEmpty);
    expect(repo.categoryIds.length, 16);
  });

  test('a full cycle visits every category exactly once, in a stable order', () {
    final categoryCount = repo.categoryIds.length;
    final seen = <String>{};
    for (var w = 0; w < categoryCount; w++) {
      seen.add(generator.worldMetaFor(w).categoryId);
    }
    expect(seen.length, categoryCount);

    // Same world index always yields the same category (determinism).
    for (var w = 0; w < categoryCount; w++) {
      expect(generator.worldMetaFor(w).categoryId, generator.worldMetaFor(w).categoryId);
    }
  });

  test('difficulty never decreases across cycles', () {
    WorldDifficulty? previous;
    for (var w = 0; w < repo.categoryIds.length * 4; w += repo.categoryIds.length) {
      final d = generator.difficultyFor(w, 0);
      if (previous != null) {
        expect(d.gridSize, greaterThanOrEqualTo(previous.gridSize));
        expect(d.wordCount, greaterThanOrEqualTo(previous.wordCount));
      }
      previous = d;
    }
  });

  test('diagonal unlocks at world 1 and reverse at world 3', () {
    expect(generator.difficultyFor(0, 0).allowDiagonal, isFalse);
    expect(generator.difficultyFor(0, 0).allowReverse, isFalse);
    expect(generator.difficultyFor(1, 0).allowDiagonal, isTrue);
    expect(generator.difficultyFor(2, 0).allowReverse, isFalse);
    expect(generator.difficultyFor(3, 0).allowReverse, isTrue);
  });

  test('buildPuzzle produces a solvable grid whose words all fit the category and language', () {
    for (final lang in ['es', 'en']) {
      for (var w in [0, 1, 3, 8, 16, 20]) {
        final puzzle = generator.buildPuzzle(worldIndex: w, levelInWorld: 0, langCode: lang);
        expect(puzzle.words, isNotEmpty);
        final categoryWords = repo.wordsFor(puzzle.categoryId, lang).toSet();
        for (final word in puzzle.words) {
          expect(categoryWords.contains(word), isTrue,
              reason: '$word should belong to category ${puzzle.categoryId} ($lang)');
          expect(word.length, lessThanOrEqualTo(puzzle.size));
        }
        // no duplicate words in the same puzzle
        expect(puzzle.words.toSet().length, puzzle.words.length);
      }
    }
  });

  test('buildPuzzle is deterministic across repeated calls', () {
    final a = generator.buildPuzzle(worldIndex: 5, levelInWorld: 3, langCode: 'es');
    final b = generator.buildPuzzle(worldIndex: 5, levelInWorld: 3, langCode: 'es');
    expect(a.letters, b.letters);
    expect(a.words, b.words);
  });

  test('progressing within a world never shrinks the grid or word count', () {
    for (var i = 1; i < WorldGenerator.levelsPerWorld; i++) {
      final prev = generator.difficultyFor(2, i - 1);
      final curr = generator.difficultyFor(2, i);
      expect(curr.gridSize, greaterThanOrEqualTo(prev.gridSize));
      expect(curr.wordCount, greaterThanOrEqualTo(prev.wordCount));
    }
  });

  test('back-to-back early levels in the same world never repeat a word', () {
    for (final lang in ['es', 'en']) {
      final level0 = generator.buildPuzzle(worldIndex: 0, levelInWorld: 0, langCode: lang);
      final level1 = generator.buildPuzzle(worldIndex: 0, levelInWorld: 1, langCode: lang);
      expect(level0.words.toSet().intersection(level1.words.toSet()), isEmpty,
          reason: '$lang: level 1 repeated a word already used in level 0');
    }
  });

  test('a world exhausts most of the category before any word repeats', () {
    for (final lang in ['es', 'en']) {
      final categorySize = repo.wordsFor(generator.worldMetaFor(0).categoryId, lang).length;
      final seenSoFar = <String>{};
      var firstRepeatAtDistinctCount = -1;
      for (var levelInWorld = 0; levelInWorld < WorldGenerator.levelsPerWorld; levelInWorld++) {
        final puzzle = generator.buildPuzzle(worldIndex: 0, levelInWorld: levelInWorld, langCode: lang);
        for (final word in puzzle.words) {
          if (seenSoFar.contains(word) && firstRepeatAtDistinctCount == -1) {
            firstRepeatAtDistinctCount = seenSoFar.length;
          }
          seenSoFar.add(word);
        }
      }
      // Once the deck wraps around, repeats are expected -- but only after
      // most of the category's words have already appeared once. (Spanish
      // words tend to run longer than their English counterparts, so more
      // of them get skipped at the smallest grid sizes -- the threshold
      // stays modest enough to hold for both languages.)
      final threshold = (categorySize * 0.5).floor();
      expect(
        firstRepeatAtDistinctCount == -1 || firstRepeatAtDistinctCount >= threshold,
        isTrue,
        reason: '$lang repeated a word after only $firstRepeatAtDistinctCount/$categorySize distinct words',
      );
    }
  });

  test('revisiting a category on a later cycle reshuffles its word order', () {
    final targetCategory = generator.worldMetaFor(0).categoryId;
    final categoryCount = repo.categoryIds.length;

    // Find whichever world in cycle 1 maps back to the same category as
    // world 0 (cycle 1 uses its own shuffled category order, so it won't
    // necessarily be worldIndex == categoryCount).
    int? cycle1World;
    for (var w = categoryCount; w < categoryCount * 2; w++) {
      if (generator.worldMetaFor(w).categoryId == targetCategory) {
        cycle1World = w;
        break;
      }
    }
    expect(cycle1World, isNotNull);

    final firstCycleWords = generator.buildPuzzle(worldIndex: 0, levelInWorld: 0, langCode: 'en').words;
    final laterCycleWords =
        generator.buildPuzzle(worldIndex: cycle1World!, levelInWorld: 0, langCode: 'en').words;
    expect(firstCycleWords, isNot(equals(laterCycleWords)));
  });
}
