import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class WordBankChips extends StatelessWidget {
  const WordBankChips({super.key, required this.words, required this.foundWords});

  final List<String> words;
  final Set<String> foundWords;

  @override
  Widget build(BuildContext context) {
    final colors = context.puzzleColors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: words.map((word) {
        final found = foundWords.contains(word);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: found ? colors.tileFoundBackground.withValues(alpha: 0.16) : colors.tileBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: found ? colors.tileFoundBackground : colors.tileBorder),
          ),
          child: Text(
            word,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: found ? colors.tileFoundBackground : colors.tileText,
              decoration: found ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}
