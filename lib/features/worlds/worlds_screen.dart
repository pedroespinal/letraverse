import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/category_names.dart';
import '../../core/providers.dart';
import '../../domain/world_generator.dart';
import '../../l10n/gen/app_localizations.dart';
import '../play/play_controller.dart';

class WorldsScreen extends ConsumerWidget {
  const WorldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(progressRepositoryProvider);
    ref.watch(progressRevisionProvider);
    final generator = ref.watch(worldGeneratorProvider);
    final wordBanks = ref.watch(wordBankRepositoryProvider);
    final langCode = Localizations.localeOf(context).languageCode;

    final highest = progress.highestUnlockedWorldIndex;
    final visibleCount = highest + 3;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.worldsScreenTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.worldsScreenSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: visibleCount,
              itemBuilder: (context, index) {
                final meta = generator.worldMetaFor(index);
                final unlocked = progress.isWorldUnlocked(index);
                final done = progress.levelsCompletedInWorld(index);
                final completed = done == WorldGenerator.levelsPerWorld;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Text(
                      wordBanks.iconFor(meta.categoryId),
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      '${l10n.playScreenWorldLabel(index + 1)} · '
                      '${categoryDisplayName(l10n, meta.categoryId)}',
                    ),
                    subtitle: Text(
                      unlocked
                          ? (completed
                              ? l10n.worldsScreenCompleted
                              : '${l10n.worldsScreenInProgress} · ${l10n.worldsScreenLevelsDone(done, WorldGenerator.levelsPerWorld)}')
                          : l10n.worldsScreenLocked,
                    ),
                    trailing: unlocked
                        ? FilledButton.tonal(
                            onPressed: () {
                              final startLevel = done < WorldGenerator.levelsPerWorld ? done : 0;
                              ref.read(playControllerProvider.notifier).jumpToLevel(
                                    worldIndex: index,
                                    levelInWorld: startLevel,
                                    langCode: langCode,
                                  );
                              StatefulNavigationShell.of(context).goBranch(0);
                            },
                            child: Text(l10n.worldsScreenPlay),
                          )
                        : const Icon(Icons.lock_outline),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
