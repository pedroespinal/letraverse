// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HiddenWords';

  @override
  String get appTagline => 'Infinite Word Search';

  @override
  String get navPlay => 'Play';

  @override
  String get navWorlds => 'Worlds';

  @override
  String get navGuide => 'Guide';

  @override
  String get navSettings => 'Settings';

  @override
  String get playScreenTimer => 'Time';

  @override
  String playScreenWordsFound(int found, int total) {
    return '$found/$total words';
  }

  @override
  String playScreenWorldLabel(int n) {
    return 'World $n';
  }

  @override
  String playScreenLevelLabel(int n, int total) {
    return 'Level $n of $total';
  }

  @override
  String get playScreenLevelComplete => 'Level complete!';

  @override
  String get playScreenNextLevel => 'Next level';

  @override
  String playScreenNewWorldUnlocked(String name) {
    return 'New world unlocked: $name!';
  }

  @override
  String get playScreenShuffle => 'Shuffle filler letters';

  @override
  String get playScreenNoActiveLevel => 'No active level';

  @override
  String get playScreenStartPlaying => 'Start playing';

  @override
  String get worldsScreenTitle => 'Infinite Worlds';

  @override
  String get worldsScreenSubtitle =>
      'Every world brings a new theme. Finish one and the engine generates the next automatically.';

  @override
  String get worldsScreenLocked => 'Locked';

  @override
  String get worldsScreenCompleted => 'Completed';

  @override
  String get worldsScreenInProgress => 'In progress';

  @override
  String worldsScreenLevelsDone(int done, int total) {
    return '$done/$total levels';
  }

  @override
  String get worldsScreenPlay => 'Play';

  @override
  String get categoryAnimals => 'Animals';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryColors => 'Colors';

  @override
  String get categoryCountries => 'Countries';

  @override
  String get categorySports => 'Sports';

  @override
  String get categoryProfessions => 'Professions';

  @override
  String get categoryBody => 'Human Body';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categoryTechnology => 'Technology';

  @override
  String get categoryEmotions => 'Emotions';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryMusic => 'Music';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categorySpace => 'Space';

  @override
  String get categorySchool => 'School';

  @override
  String get guideScreenTitle => 'User Guide';

  @override
  String get guideHowToPlayTitle => 'How to play';

  @override
  String get guideHowToPlayBody =>
      'Drag your finger from the first to the last letter of a word hidden in the grid. It can run horizontally, vertically, or diagonally, forwards or backwards once you unlock that difficulty. Find every word on the list to complete the level.';

  @override
  String get guideWorldsTitle => 'Infinite worlds';

  @override
  String get guideWorldsBody =>
      'Each world groups 8 levels around one theme. As you approach the end of your unlocked worlds, the app generates the next one automatically: a new theme, a bigger grid, more words. It never runs out.';

  @override
  String get guideLangThemeTitle => 'Language and theme';

  @override
  String get guideLangThemeBody =>
      'Switch language (Español/English) and theme (light/dark) anytime from Settings. Your letters always stay legible in both modes.';

  @override
  String get guideUpdatesTitle => 'Updates';

  @override
  String get guideUpdatesBody =>
      'The app checks GitHub Releases on launch. If a new version exists, it offers a button to download and install it (Android) or open the download page (iOS).';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'Automatic';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'Automatic';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsAboutVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String settingsAboutGenesis(String date) {
    return 'App created on $date';
  }

  @override
  String get settingsCheckUpdates => 'Check for updates';

  @override
  String get settingsResetProgress => 'Reset progress';

  @override
  String get settingsResetProgressConfirm =>
      'Are you sure you want to erase all your progress? This cannot be undone.';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version) {
    return 'A new version ($version) of HiddenWords is available.';
  }

  @override
  String get updateDownloadInstall => 'Download & install';

  @override
  String get updateOpenReleasePage => 'Open download page';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloading => 'Downloading update…';

  @override
  String get updateUpToDate => 'You\'re on the latest version';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonClose => 'Close';

  @override
  String get footerCredit =>
      'Created by: Pedro Espinal — All rights reserved © 2026';
}
