import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';
import 'domain/word_bank_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final wordBanks = WordBankRepository();
  await wordBanks.load();

  await Hive.initFlutter();
  final progressBox = await Hive.openBox<dynamic>('progress');

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        wordBankRepositoryProvider.overrideWithValue(wordBanks),
        progressRepositoryProvider.overrideWithValue(ProgressRepository(progressBox)),
        settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
      ],
      child: const HiddenWordsApp(),
    ),
  );
}
