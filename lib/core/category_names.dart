import '../l10n/gen/app_localizations.dart';

/// Maps a stable category id (used in code/data) to its localized display
/// name. Keeping this in one place means adding a language only ever means
/// adding ARB keys, never touching the domain layer.
String categoryDisplayName(AppLocalizations l10n, String categoryId) {
  switch (categoryId) {
    case 'animals':
      return l10n.categoryAnimals;
    case 'fruits':
      return l10n.categoryFruits;
    case 'colors':
      return l10n.categoryColors;
    case 'countries':
      return l10n.categoryCountries;
    case 'sports':
      return l10n.categorySports;
    case 'professions':
      return l10n.categoryProfessions;
    case 'body':
      return l10n.categoryBody;
    case 'nature':
      return l10n.categoryNature;
    case 'technology':
      return l10n.categoryTechnology;
    case 'emotions':
      return l10n.categoryEmotions;
    case 'transport':
      return l10n.categoryTransport;
    case 'music':
      return l10n.categoryMusic;
    case 'food':
      return l10n.categoryFood;
    case 'clothing':
      return l10n.categoryClothing;
    case 'space':
      return l10n.categorySpace;
    case 'school':
      return l10n.categorySchool;
    default:
      return categoryId;
  }
}
