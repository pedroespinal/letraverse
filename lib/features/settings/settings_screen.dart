import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_genesis.dart';
import '../../core/date_format.dart';
import '../../core/package_info_provider.dart';
import '../../core/providers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../update/update_flow.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final packageInfoAsync = ref.watch(packageInfoProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    Future<void> setLocale(Locale? next) async {
      ref.read(localeProvider.notifier).state = next;
      await ref.read(settingsRepositoryProvider).setLocale(next);
    }

    Future<void> setTheme(ThemeMode next) async {
      ref.read(themeModeProvider.notifier).state = next;
      await ref.read(settingsRepositoryProvider).setThemeMode(next);
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l10n.settingsScreenTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _SectionCard(
            title: l10n.settingsLanguage,
            child: SegmentedButton<Locale?>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: null, label: Text(l10n.settingsLanguageSystem, softWrap: false, overflow: TextOverflow.ellipsis)),
                ButtonSegment(value: const Locale('es'), label: Text(l10n.settingsLanguageSpanish, softWrap: false, overflow: TextOverflow.ellipsis)),
                ButtonSegment(value: const Locale('en'), label: Text(l10n.settingsLanguageEnglish, softWrap: false, overflow: TextOverflow.ellipsis)),
              ],
              selected: {locale},
              onSelectionChanged: (selection) => setLocale(selection.first),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.settingsTheme,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.settingsThemeSystem, softWrap: false, overflow: TextOverflow.ellipsis)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.settingsThemeLight, softWrap: false, overflow: TextOverflow.ellipsis)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.settingsThemeDark, softWrap: false, overflow: TextOverflow.ellipsis)),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) => setTheme(selection.first),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.guideUpdatesTitle,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.system_update_alt_outlined),
              title: Text(l10n.settingsCheckUpdates),
              onTap: () => presentUpdateIfAvailable(context, ref, silentWhenUpToDate: false),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.settingsAbout,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                packageInfoAsync.when(
                  data: (info) => Text(l10n.settingsAboutVersion(info.version, info.buildNumber)),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 4),
                Text(l10n.settingsAboutGenesis(formatLongDate(kAppGenesisUtc, langCode))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.settingsResetProgress,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.settingsResetProgress),
              onPressed: () => _confirmReset(context, ref, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.settingsResetProgressConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(progressRepositoryProvider).resetAll();
      ref.read(progressRevisionProvider.notifier).state++;
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
