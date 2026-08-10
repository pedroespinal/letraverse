import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/progress_repository.dart';
import '../data/settings_repository.dart';
import '../data/stats_repository.dart';
import '../domain/word_bank_repository.dart';
import '../domain/world_generator.dart';

/// These four are provided real instances via [ProviderScope.overrides] in
/// main() once their async setup (asset loading / Hive / SharedPreferences)
/// completes. Reading them before that override is a programming error, so
/// they intentionally throw rather than silently returning a stub.
final wordBankRepositoryProvider = Provider<WordBankRepository>(
  (ref) => throw UnimplementedError('wordBankRepositoryProvider must be overridden in main()'),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => throw UnimplementedError('progressRepositoryProvider must be overridden in main()'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('settingsRepositoryProvider must be overridden in main()'),
);

final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => throw UnimplementedError('statsRepositoryProvider must be overridden in main()'),
);

/// Bumped whenever stats change so widgets watching them rebuild.
final statsRevisionProvider = StateProvider<int>((ref) => 0);

final worldGeneratorProvider = Provider<WorldGenerator>(
  (ref) => WorldGenerator(ref.watch(wordBankRepositoryProvider)),
);

final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ref.watch(settingsRepositoryProvider).themeMode,
);

final localeProvider = StateProvider<Locale?>(
  (ref) => ref.watch(settingsRepositoryProvider).locale,
);

/// Bumped whenever progress changes so widgets watching it rebuild without
/// needing ProgressRepository itself to be a ChangeNotifier.
final progressRevisionProvider = StateProvider<int>((ref) => 0);

/// Gates the automatic "check GitHub for a newer release" call the app
/// fires on launch. Real app runs leave this true; widget tests override it
/// to false so a test never makes a live network call (which flutter test's
/// fake-async clock cannot resolve, and would hang the run).
final autoUpdateCheckEnabledProvider = Provider<bool>((ref) => true);
