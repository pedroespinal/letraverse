import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/category_names.dart';
import '../../core/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import 'play_controller.dart';
import 'widgets/letter_grid.dart';
import 'widgets/word_bank_chips.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  String? _lastLangCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final langCode = Localizations.localeOf(context).languageCode;
    if (_lastLangCode != langCode) {
      _lastLangCode = langCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(playControllerProvider.notifier).loadCurrentPuzzle(langCode);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(playControllerProvider);
    final puzzle = state.puzzle;
    final colors = context.puzzleColors;

    ref.listen(playControllerProvider.select((s) => s.isComplete), (previous, isComplete) {
      if (isComplete == true) {
        _showCompletionSheet(context, l10n);
      }
    });

    if (puzzle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final minutes = state.elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (state.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.justUnlockedWorldIndex != null) _UnlockBanner(l10n: l10n, worldIndex: state.justUnlockedWorldIndex!),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${categoryDisplayName(l10n, puzzle.categoryId)} · '
                    '${l10n.playScreenWorldLabel(state.worldIndex + 1)}',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: colors.tileText.withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text('$minutes:$seconds'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              l10n.playScreenLevelLabel(state.levelInWorld + 1, 8),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(l10n.playScreenWordsFound(state.foundWords.length, puzzle.words.length)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.touch_app_outlined, size: 14, color: colors.tileText.withValues(alpha: 0.55)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.playScreenSelectionHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.tileText.withValues(alpha: 0.55),
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Both the grid and the word list live inside this Expanded so
            // they always share whatever vertical space is actually left,
            // however tall the header above happens to be — an AspectRatio
            // grid placed directly in an unbounded Column would instead try
            // to grow to the full screen width and overflow on short/wide
            // viewports (e.g. small-height phones in landscape).
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(child: LetterGrid()),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: WordBankChips(words: puzzle.words, foundWords: state.foundWords),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration_outlined, size: 48),
            const SizedBox(height: 12),
            Text(l10n.playScreenLevelComplete, style: Theme.of(sheetContext).textTheme.headlineSmall),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                final langCode = Localizations.localeOf(context).languageCode;
                ref.read(playControllerProvider.notifier).goToNextLevel(langCode);
              },
              child: Text(l10n.playScreenNextLevel),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnlockBanner extends ConsumerWidget {
  const _UnlockBanner({required this.l10n, required this.worldIndex});

  final AppLocalizations l10n;
  final int worldIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('unlock-$worldIndex'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => ref.read(playControllerProvider.notifier).acknowledgeWorldUnlock(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.playScreenNewWorldUnlocked(l10n.playScreenWorldLabel(worldIndex + 1))),
            ),
          ],
        ),
      ),
    );
  }
}
