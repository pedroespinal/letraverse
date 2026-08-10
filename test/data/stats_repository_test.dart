import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:hiddenwords/data/stats_repository.dart';

void main() {
  Future<StatsRepository> makeRepo({DateTime Function()? now}) async {
    final box = await Hive.openBox<dynamic>(
      'stats-test-${DateTime.now().microsecondsSinceEpoch}',
      bytes: Uint8List(0),
    );
    return StatsRepository(box, now: now);
  }

  test('starts at zero', () async {
    final repo = await makeRepo();
    expect(repo.totalWordsFound, 0);
    expect(repo.totalLevelsCompleted, 0);
    expect(repo.currentStreak, 0);
    expect(repo.bestStreak, 0);
  });

  test('recordWordFound increments the running total', () async {
    final repo = await makeRepo();
    await repo.recordWordFound();
    await repo.recordWordFound();
    expect(repo.totalWordsFound, 2);
  });

  test('recordLevelCompleted tracks levels and accumulated play time', () async {
    final repo = await makeRepo(now: () => DateTime(2026, 1, 1));
    await repo.recordLevelCompleted(const Duration(seconds: 90));
    await repo.recordLevelCompleted(const Duration(seconds: 30));
    expect(repo.totalLevelsCompleted, 2);
    expect(repo.totalPlaySeconds, 120);
  });

  test('first level completed ever starts a streak of 1', () async {
    final repo = await makeRepo(now: () => DateTime(2026, 1, 1));
    await repo.recordLevelCompleted(const Duration(seconds: 10));
    expect(repo.currentStreak, 1);
    expect(repo.bestStreak, 1);
  });

  test('playing again the same day does not change the streak', () async {
    var hour = 9;
    final repo = await makeRepo(now: () => DateTime(2026, 1, 1, hour));

    await repo.recordLevelCompleted(const Duration(seconds: 10));
    expect(repo.currentStreak, 1);

    hour = 20; // later the same day
    await repo.recordLevelCompleted(const Duration(seconds: 10));
    expect(repo.currentStreak, 1);
    expect(repo.totalLevelsCompleted, 2);
  });

  test('playing on consecutive days extends the streak', () async {
    var day = 1;
    final repo = await makeRepo(now: () => DateTime(2026, 1, day));

    day = 1;
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    expect(repo.currentStreak, 1);

    day = 2;
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    expect(repo.currentStreak, 2);

    day = 3;
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    expect(repo.currentStreak, 3);
    expect(repo.bestStreak, 3);
  });

  test('skipping a day resets the streak but keeps the best streak', () async {
    var day = 1;
    final repo = await makeRepo(now: () => DateTime(2026, 1, day));

    day = 1;
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    day = 2;
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    expect(repo.currentStreak, 2);

    day = 4; // skipped day 3
    await repo.recordLevelCompleted(const Duration(seconds: 5));
    expect(repo.currentStreak, 1);
    expect(repo.bestStreak, 2);
  });

  test('resetAll clears every stat back to zero', () async {
    final repo = await makeRepo(now: () => DateTime(2026, 1, 1));
    await repo.recordWordFound();
    await repo.recordLevelCompleted(const Duration(seconds: 30));
    await repo.resetAll();
    expect(repo.totalWordsFound, 0);
    expect(repo.totalLevelsCompleted, 0);
    expect(repo.currentStreak, 0);
  });
}
