import 'package:hive/hive.dart';

/// Lightweight play stats -- total words found, levels completed, time
/// played, and a daily streak -- stored in their own Hive box so they can
/// be reset independently of level progress if we ever want that.
class StatsRepository {
  StatsRepository(this._box, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final Box<dynamic> _box;
  final DateTime Function() _now;

  static const _totalWordsFoundKey = 'totalWordsFound';
  static const _totalLevelsCompletedKey = 'totalLevelsCompleted';
  static const _totalPlaySecondsKey = 'totalPlaySeconds';
  static const _currentStreakKey = 'currentStreak';
  static const _bestStreakKey = 'bestStreak';
  static const _lastPlayedDateKey = 'lastPlayedDate';

  int get totalWordsFound => (_box.get(_totalWordsFoundKey, defaultValue: 0) as int);
  int get totalLevelsCompleted => (_box.get(_totalLevelsCompletedKey, defaultValue: 0) as int);
  int get totalPlaySeconds => (_box.get(_totalPlaySecondsKey, defaultValue: 0) as int);
  int get currentStreak => (_box.get(_currentStreakKey, defaultValue: 0) as int);
  int get bestStreak => (_box.get(_bestStreakKey, defaultValue: 0) as int);

  Future<void> recordWordFound() async {
    await _box.put(_totalWordsFoundKey, totalWordsFound + 1);
  }

  Future<void> recordLevelCompleted(Duration elapsed) async {
    await _box.put(_totalLevelsCompletedKey, totalLevelsCompleted + 1);
    await _box.put(_totalPlaySecondsKey, totalPlaySeconds + elapsed.inSeconds);
    await _updateStreak(_now());
  }

  Future<void> _updateStreak(DateTime now) async {
    final todayKey = _dateKey(now);
    final lastKey = _box.get(_lastPlayedDateKey) as String?;

    if (lastKey == todayKey) {
      return; // already played today, streak unchanged
    }

    final yesterdayKey = _dateKey(now.subtract(const Duration(days: 1)));
    final newStreak = lastKey == yesterdayKey ? currentStreak + 1 : 1;

    await _box.put(_currentStreakKey, newStreak);
    if (newStreak > bestStreak) {
      await _box.put(_bestStreakKey, newStreak);
    }
    await _box.put(_lastPlayedDateKey, todayKey);
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> resetAll() async {
    await _box.clear();
  }
}
