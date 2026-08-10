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
    final categoryIds = wordBanks.categoryIds;

    void jumpTo(int worldIndex) {
      final done = progress.levelsCompletedInWorld(worldIndex);
      final startLevel = done < WorldGenerator.levelsPerWorld ? done : 0;
      ref.read(playControllerProvider.notifier).jumpToLevel(
            worldIndex: worldIndex,
            levelInWorld: startLevel,
            langCode: langCode,
          );
      StatefulNavigationShell.of(context).goBranch(0);
    }

    Widget buildHeader(BuildContext context) {
      return Padding(
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
            const SizedBox(height: 20),
            Text(l10n.worldsScreenPickCategory, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              l10n.worldsScreenPickCategorySubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final categoryId in categoryIds)
                  ActionChip(
                    avatar: Text(wordBanks.iconFor(categoryId), style: const TextStyle(fontSize: 16)),
                    label: Text(categoryDisplayName(l10n, categoryId)),
                    // Every category has a stable "home" world in cycle 0
                    // (its position in the base category order),
                    // independent of sequential world-unlock progress --
                    // tapping it plays that category on demand instead of
                    // waiting to unlock it.
                    onPressed: () => jumpTo(categoryIds.indexOf(categoryId)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return SafeArea(
      bottom: false,
      // The category picker can wrap across several lines (16 chips), so
      // the header has to scroll together with the world list below it
      // instead of being pinned above a separately-scrolling Expanded --
      // pinning it caused a bottom overflow on shorter screens. It's item
      // 0 of the same ListView.builder, so it's still built lazily.
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: visibleCount + 1,
        itemBuilder: (context, i) {
          if (i == 0) return buildHeader(context);
          final index = i - 1;

          final meta = generator.worldMetaFor(index);
          final unlocked = progress.isWorldUnlocked(index);
          final done = progress.levelsCompletedInWorld(index);
          final completed = done == WorldGenerator.levelsPerWorld;

          return Card(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
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
                      onPressed: () => jumpTo(index),
                      child: Text(l10n.worldsScreenPlay),
                    )
                  : const Icon(Icons.lock_outline),
            ),
          );
        },
      ),
    );
  }
}
