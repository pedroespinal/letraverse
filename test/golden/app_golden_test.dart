// Golden tests for the two screens most likely to regress visually: the
// puzzle grid (Play tab) and the settings/stats screen. These render on the
// same Flutter SDK used by scripts/build_release.ps1 (the canonical local
// build machine), so they are a hard gate there. They are deliberately
// excluded from .github/workflows/release.yml's audit step, since that CI
// runs on different OS/Flutter-patch combinations that aren't guaranteed to
// rasterize pixel-identically.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:letraverse/app.dart';
import 'package:letraverse/core/providers.dart';
import 'package:letraverse/data/progress_repository.dart';
import 'package:letraverse/data/settings_repository.dart';
import 'package:letraverse/data/stats_repository.dart';
import 'package:letraverse/domain/word_bank_repository.dart';

void main() {
  late final WordBankRepository wordBanks;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    wordBanks = WordBankRepository();
    await wordBanks.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Letraverse',
      packageName: 'com.pedroespinal.letraverse',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  tearDown(() async {
    await Hive.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final progressBox = await Hive.openBox<dynamic>('progress', bytes: Uint8List(0));
    final statsBox = await Hive.openBox<dynamic>('stats', bytes: Uint8List(0));
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wordBankRepositoryProvider.overrideWithValue(wordBanks),
          progressRepositoryProvider.overrideWithValue(ProgressRepository(progressBox)),
          settingsRepositoryProvider.overrideWithValue(SettingsRepository(prefs)),
          statsRepositoryProvider.overrideWithValue(StatsRepository(statsBox)),
          autoUpdateCheckEnabledProvider.overrideWithValue(false),
          // Golden images must not depend on the host machine's locale/theme.
          localeProvider.overrideWith((ref) => const Locale('en')),
          themeModeProvider.overrideWith((ref) => ThemeMode.light),
        ],
        child: const LetraverseApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('play screen puzzle grid matches golden', (tester) async {
    await pumpApp(tester);

    await expectLater(find.byType(LetraverseApp), matchesGoldenFile('golden_files/play_screen.png'));

    await unmount(tester);
  }, tags: 'golden');

  testWidgets('settings screen with stats matches golden', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await expectLater(find.byType(LetraverseApp), matchesGoldenFile('golden_files/settings_screen.png'));

    await unmount(tester);
  }, tags: 'golden');
}
