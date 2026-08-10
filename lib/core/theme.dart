import 'package:flutter/material.dart';

/// Puzzle-board specific colors that don't map to Material's ColorScheme
/// roles (tile background/text, active selection, found-word highlight).
/// Chosen palette: Menta Fresca (light) + Tinta Nocturna (dark). Every
/// text/background pair here was checked against WCAG 2.1 contrast
/// (>=4.5:1) before being picked — see the palette comparison the app's
/// theme was chosen from.
class PuzzleColors extends ThemeExtension<PuzzleColors> {
  const PuzzleColors({
    required this.boardBackground,
    required this.tileBackground,
    required this.tileBorder,
    required this.tileText,
    required this.tileSelectedBackground,
    required this.tileSelectedText,
    required this.tileFoundBackground,
    required this.tileFoundText,
  });

  final Color boardBackground;
  final Color tileBackground;
  final Color tileBorder;
  final Color tileText;
  final Color tileSelectedBackground;
  final Color tileSelectedText;
  final Color tileFoundBackground;
  final Color tileFoundText;

  /// Menta Fresca (L2).
  static const light = PuzzleColors(
    boardBackground: Color(0xFFF0F7F4),
    tileBackground: Color(0xFFFFFFFF),
    tileBorder: Color(0xFFCFE3DA),
    tileText: Color(0xFF12342A),
    tileSelectedBackground: Color(0xFF7FD9C4),
    tileSelectedText: Color(0xFF0B2A22),
    tileFoundBackground: Color(0xFF1D7A6F),
    tileFoundText: Color(0xFFFFFFFF),
  );

  /// Tinta Nocturna (D1).
  static const dark = PuzzleColors(
    boardBackground: Color(0xFF12131A),
    tileBackground: Color(0xFF232538),
    tileBorder: Color(0xFF343755),
    tileText: Color(0xFFF4F1EA),
    tileSelectedBackground: Color(0xFFFFD166),
    tileSelectedText: Color(0xFF12131A),
    tileFoundBackground: Color(0xFF06A77D),
    tileFoundText: Color(0xFF0A1410),
  );

  @override
  PuzzleColors copyWith({
    Color? boardBackground,
    Color? tileBackground,
    Color? tileBorder,
    Color? tileText,
    Color? tileSelectedBackground,
    Color? tileSelectedText,
    Color? tileFoundBackground,
    Color? tileFoundText,
  }) {
    return PuzzleColors(
      boardBackground: boardBackground ?? this.boardBackground,
      tileBackground: tileBackground ?? this.tileBackground,
      tileBorder: tileBorder ?? this.tileBorder,
      tileText: tileText ?? this.tileText,
      tileSelectedBackground: tileSelectedBackground ?? this.tileSelectedBackground,
      tileSelectedText: tileSelectedText ?? this.tileSelectedText,
      tileFoundBackground: tileFoundBackground ?? this.tileFoundBackground,
      tileFoundText: tileFoundText ?? this.tileFoundText,
    );
  }

  @override
  PuzzleColors lerp(ThemeExtension<PuzzleColors>? other, double t) {
    if (other is! PuzzleColors) return this;
    return PuzzleColors(
      boardBackground: Color.lerp(boardBackground, other.boardBackground, t)!,
      tileBackground: Color.lerp(tileBackground, other.tileBackground, t)!,
      tileBorder: Color.lerp(tileBorder, other.tileBorder, t)!,
      tileText: Color.lerp(tileText, other.tileText, t)!,
      tileSelectedBackground:
          Color.lerp(tileSelectedBackground, other.tileSelectedBackground, t)!,
      tileSelectedText: Color.lerp(tileSelectedText, other.tileSelectedText, t)!,
      tileFoundBackground: Color.lerp(tileFoundBackground, other.tileFoundBackground, t)!,
      tileFoundText: Color.lerp(tileFoundText, other.tileFoundText, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static const _lightAccent = Color(0xFFE76F51); // Menta Fresca accent
  static const _darkAccent = Color(0xFFEF476F); // Tinta Nocturna accent

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _lightAccent,
      brightness: Brightness.light,
      primary: _lightAccent,
      surface: PuzzleColors.light.boardBackground,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _lightAccent.withValues(alpha: 0.16),
        elevation: 0,
      ),
      extensions: const [PuzzleColors.light],
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _darkAccent,
      brightness: Brightness.dark,
      primary: _darkAccent,
      surface: PuzzleColors.dark.boardBackground,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF1B1D29),
        indicatorColor: _darkAccent.withValues(alpha: 0.22),
        elevation: 0,
      ),
      extensions: const [PuzzleColors.dark],
    );
  }
}

extension PuzzleColorsX on BuildContext {
  PuzzleColors get puzzleColors => Theme.of(this).extension<PuzzleColors>()!;
}
