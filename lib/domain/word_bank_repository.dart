import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class WordCategory {
  const WordCategory({required this.id, required this.icon, required this.words});
  final String id;
  final String icon;
  final List<String> words;
}

/// Loads the bilingual, curated word banks bundled as assets and exposes
/// them by category id. Both language files must declare the same category
/// ids (enforced by [load] as a startup invariant, not a runtime guess).
class WordBankRepository {
  final Map<String, Map<String, WordCategory>> _byLangThenCategory = {};
  List<String> _categoryOrder = const [];
  bool _loaded = false;

  List<String> get categoryIds => _categoryOrder;

  Future<void> load() async {
    if (_loaded) return;
    final es = await _loadLang('es');
    final en = await _loadLang('en');
    final esIds = es.keys.toSet();
    final enIds = en.keys.toSet();
    if (esIds.length != enIds.length || !esIds.containsAll(enIds)) {
      throw StateError(
        'Los bancos de palabras ES/EN tienen categorías distintas: '
        '${esIds.difference(enIds)} vs ${enIds.difference(esIds)}',
      );
    }
    _byLangThenCategory['es'] = es;
    _byLangThenCategory['en'] = en;
    _categoryOrder = es.keys.toList(growable: false);
    _loaded = true;
  }

  Future<Map<String, WordCategory>> _loadLang(String lang) async {
    final raw = await rootBundle.loadString('assets/wordbanks/$lang/wordbank.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = (json['categories'] as List<dynamic>).cast<Map<String, dynamic>>();
    return {
      for (final c in categories)
        c['id'] as String: WordCategory(
          id: c['id'] as String,
          icon: c['icon'] as String,
          words: (c['words'] as List<dynamic>).cast<String>(),
        ),
    };
  }

  List<String> wordsFor(String categoryId, String langCode) {
    _assertLoaded();
    final lang = _byLangThenCategory[langCode] ?? _byLangThenCategory['en']!;
    return lang[categoryId]?.words ?? const [];
  }

  String iconFor(String categoryId) {
    _assertLoaded();
    return _byLangThenCategory['es']?[categoryId]?.icon ?? '🔤';
  }

  void _assertLoaded() {
    if (!_loaded) {
      throw StateError('WordBankRepository.load() no se ha llamado todavía.');
    }
  }
}
