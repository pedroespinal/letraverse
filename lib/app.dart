import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/update/update_flow.dart';
import 'l10n/gen/app_localizations.dart';

class LetraverseApp extends ConsumerStatefulWidget {
  const LetraverseApp({super.key});

  @override
  ConsumerState<LetraverseApp> createState() => _LetraverseAppState();
}

class _LetraverseAppState extends ConsumerState<LetraverseApp> {
  bool _checkedForUpdate = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'Letraverse',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        if (!_checkedForUpdate && ref.read(autoUpdateCheckEnabledProvider)) {
          _checkedForUpdate = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) presentUpdateIfAvailable(context, ref);
          });
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
