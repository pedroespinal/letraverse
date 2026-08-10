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
import 'package:letraverse/features/play/widgets/letter_grid.dart';
import 'package:letraverse/widgets/app_footer.dart';

void main() {
  // Loaded once and reused: the word banks are static asset data, so every
  // test re-loading them from scratch is both wasteful and (empirically, in
  // this sandboxed environment) fragile -- a second `rootBundle` asset load
  // issued right after a widget tree teardown was observed to hang.
  late final WordBankRepository wordBanks;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    wordBanks = WordBankRepository();
    await wordBanks.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // StatefulShellRoute.indexedStack builds every branch up front (so tab
    // state survives switching), which means SettingsScreen -- and its
    // PackageInfo.fromPlatform() platform-channel call -- mounts on the
    // very first frame even though Play is the visible tab.
    PackageInfo.setMockInitialValues(
      appName: 'Letraverse',
      packageName: 'com.pedroespinal.letraverse',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  tearDown(() async {
    // deleteFromDisk() throws for memory-backed boxes ("unsupported for
    // memory boxes") — close() tears them down without touching disk.
    await Hive.close();
  });

  // NOTE: deliberately uses bounded pump() calls, never pumpAndSettle().
  // The Play tab runs a real 1-second Timer.periodic for the level clock,
  // and StatefulShellRoute.indexedStack keeps every tab's widget tree (and
  // therefore that timer) alive even while another tab is on screen. That
  // means frames never stop being scheduled, so pumpAndSettle() would spin
  // until its 10-minute internal timeout instead of returning.
  Future<void> pumpApp(WidgetTester tester) async {
    // In-memory Hive box: a real file-backed box calls RandomAccessFile.lock()
    // under the hood, which hangs indefinitely in this sandboxed test
    // environment. `bytes:` makes Hive use its in-memory backend instead, so
    // no disk/file-lock syscall is ever made.
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
        ],
        child: const LetraverseApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  // PlayScreen's level clock is a real Timer.periodic, and it lives as long
  // as its ProviderScope does. Flutter's test framework does not tear down
  // the previous test's widget tree for you between testWidgets() blocks in
  // the same file, so without this the timer from test N survives into test
  // N+1's fake-async zone, still firing every virtual second — the next
  // test then deadlocks (confirmed by sampling CPU: 0% usage, i.e. genuinely
  // stuck, not just slow). Explicitly unmounting forces PlayController's
  // dispose() (which cancels the timer) to run before the next test starts.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('boots straight into a playable puzzle with nav shell and footer', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppFooter), findsOneWidget);
    expect(find.byType(LetterGrid), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('the footer stays mounted after switching tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.public_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AppFooter), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AppFooter), findsOneWidget);

    await unmount(tester);
  });
}
