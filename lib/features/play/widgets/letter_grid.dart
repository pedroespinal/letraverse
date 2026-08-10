import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../domain/models/placed_word.dart';
import '../../../domain/models/puzzle.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../play_controller.dart';
import '../selection_path.dart';

class LetterGrid extends ConsumerWidget {
  const LetterGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(playControllerProvider);
    final puzzle = state.puzzle;
    final colors = context.puzzleColors;
    if (puzzle == null) return const SizedBox.shrink();

    final foundCells = _foundCellSet(puzzle, state.foundWords);
    final selectionSet = state.selection.toSet();
    final controller = ref.read(playControllerProvider.notifier);

    return Semantics(
      label: l10n.playScreenBoardLabel(puzzle.size),
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / puzzle.size;

            (int, int) cellAt(Offset local) {
              final col = (local.dx / cellSize).floor().clamp(0, puzzle.size - 1).toInt();
              final row = (local.dy / cellSize).floor().clamp(0, puzzle.size - 1).toInt();
              return (row, col);
            }

            return GestureDetector(
              onPanStart: (details) => controller.updateSelection([cellAt(details.localPosition)]),
              onPanUpdate: (details) {
                if (state.selection.isEmpty) return;
                final path = computeSelectionPath(state.selection.first, cellAt(details.localPosition));
                controller.updateSelection(path);
              },
              onPanEnd: (_) => controller.submitSelection(),
              // Accessibility / motor-impairment alternative to dragging:
              // tap the first letter, then tap the last letter of the word.
              // Tapping the same (only) selected cell again cancels it.
              onTapUp: (details) {
                final cell = cellAt(details.localPosition);
                if (state.selection.isEmpty) {
                  controller.updateSelection([cell]);
                } else if (state.selection.length == 1 && state.selection.first == cell) {
                  controller.updateSelection(const []);
                } else {
                  controller.updateSelection(computeSelectionPath(state.selection.first, cell));
                  controller.submitSelection();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colors.boardBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(6),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: puzzle.size),
                  itemCount: puzzle.size * puzzle.size,
                  itemBuilder: (context, index) {
                    final row = index ~/ puzzle.size;
                    final col = index % puzzle.size;
                    final letter = puzzle.letters[row][col];
                    final isFound = foundCells.contains((row, col));
                    final isSelected = selectionSet.contains((row, col));

                    Color bg = colors.tileBackground;
                    Color fg = colors.tileText;
                    if (isFound) {
                      bg = colors.tileFoundBackground;
                      fg = colors.tileFoundText;
                    } else if (isSelected) {
                      bg = colors.tileSelectedBackground;
                      fg = colors.tileSelectedText;
                    }

                    final semanticLabel = [
                      l10n.playScreenCellLabel(letter, row + 1, col + 1),
                      if (isFound) l10n.playScreenCellFound,
                      if (isSelected) l10n.playScreenCellSelected,
                    ].join(', ');

                    return Semantics(
                      label: semanticLabel,
                      child: Container(
                        margin: const EdgeInsets.all(1.4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: colors.tileBorder, width: 0.6),
                        ),
                        child: FittedBox(
                          child: Text(
                            letter,
                            style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Set<(int, int)> _foundCellSet(Puzzle puzzle, Set<String> foundWords) {
    final cells = <(int, int)>{};
    for (final PlacedWord placed in puzzle.placedWords) {
      if (foundWords.contains(placed.word)) {
        cells.addAll(placed.cells);
      }
    }
    return cells;
  }
}
