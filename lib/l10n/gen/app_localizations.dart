import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Letraverse'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In es, this message translates to:
  /// **'Sopa de Letras Infinita'**
  String get appTagline;

  /// No description provided for @navPlay.
  ///
  /// In es, this message translates to:
  /// **'Jugar'**
  String get navPlay;

  /// No description provided for @navWorlds.
  ///
  /// In es, this message translates to:
  /// **'Mundos'**
  String get navWorlds;

  /// No description provided for @navGuide.
  ///
  /// In es, this message translates to:
  /// **'Guía'**
  String get navGuide;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @playScreenTimer.
  ///
  /// In es, this message translates to:
  /// **'Tiempo'**
  String get playScreenTimer;

  /// No description provided for @playScreenWordsFound.
  ///
  /// In es, this message translates to:
  /// **'{found}/{total} palabras'**
  String playScreenWordsFound(int found, int total);

  /// No description provided for @playScreenWorldLabel.
  ///
  /// In es, this message translates to:
  /// **'Mundo {n}'**
  String playScreenWorldLabel(int n);

  /// No description provided for @playScreenLevelLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {n} de {total}'**
  String playScreenLevelLabel(int n, int total);

  /// No description provided for @playScreenLevelComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Nivel completado!'**
  String get playScreenLevelComplete;

  /// No description provided for @playScreenNextLevel.
  ///
  /// In es, this message translates to:
  /// **'Siguiente nivel'**
  String get playScreenNextLevel;

  /// No description provided for @playScreenNewWorldUnlocked.
  ///
  /// In es, this message translates to:
  /// **'¡Nuevo mundo desbloqueado: {name}!'**
  String playScreenNewWorldUnlocked(String name);

  /// No description provided for @playScreenShuffle.
  ///
  /// In es, this message translates to:
  /// **'Mezclar letras señuelo'**
  String get playScreenShuffle;

  /// No description provided for @playScreenNoActiveLevel.
  ///
  /// In es, this message translates to:
  /// **'No hay un nivel activo'**
  String get playScreenNoActiveLevel;

  /// No description provided for @playScreenStartPlaying.
  ///
  /// In es, this message translates to:
  /// **'Empezar a jugar'**
  String get playScreenStartPlaying;

  /// No description provided for @playScreenSelectionHint.
  ///
  /// In es, this message translates to:
  /// **'Arrastra, o toca la primera y la última letra'**
  String get playScreenSelectionHint;

  /// No description provided for @playScreenCellLabel.
  ///
  /// In es, this message translates to:
  /// **'Letra {letter}, fila {row}, columna {col}'**
  String playScreenCellLabel(String letter, int row, int col);

  /// No description provided for @playScreenCellFound.
  ///
  /// In es, this message translates to:
  /// **'palabra encontrada'**
  String get playScreenCellFound;

  /// No description provided for @playScreenCellSelected.
  ///
  /// In es, this message translates to:
  /// **'seleccionada'**
  String get playScreenCellSelected;

  /// No description provided for @playScreenBoardLabel.
  ///
  /// In es, this message translates to:
  /// **'Tablero de sopa de letras, {size} por {size}'**
  String playScreenBoardLabel(int size);

  /// No description provided for @worldsScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Mundos Infinitos'**
  String get worldsScreenTitle;

  /// No description provided for @worldsScreenSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada mundo trae un tema nuevo. Al terminar uno, el motor genera el siguiente automáticamente.'**
  String get worldsScreenSubtitle;

  /// No description provided for @worldsScreenLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get worldsScreenLocked;

  /// No description provided for @worldsScreenCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completado'**
  String get worldsScreenCompleted;

  /// No description provided for @worldsScreenInProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get worldsScreenInProgress;

  /// No description provided for @worldsScreenLevelsDone.
  ///
  /// In es, this message translates to:
  /// **'{done}/{total} niveles'**
  String worldsScreenLevelsDone(int done, int total);

  /// No description provided for @worldsScreenPlay.
  ///
  /// In es, this message translates to:
  /// **'Jugar'**
  String get worldsScreenPlay;

  /// No description provided for @categoryAnimals.
  ///
  /// In es, this message translates to:
  /// **'Animales'**
  String get categoryAnimals;

  /// No description provided for @categoryFruits.
  ///
  /// In es, this message translates to:
  /// **'Frutas'**
  String get categoryFruits;

  /// No description provided for @categoryColors.
  ///
  /// In es, this message translates to:
  /// **'Colores'**
  String get categoryColors;

  /// No description provided for @categoryCountries.
  ///
  /// In es, this message translates to:
  /// **'Países'**
  String get categoryCountries;

  /// No description provided for @categorySports.
  ///
  /// In es, this message translates to:
  /// **'Deportes'**
  String get categorySports;

  /// No description provided for @categoryProfessions.
  ///
  /// In es, this message translates to:
  /// **'Profesiones'**
  String get categoryProfessions;

  /// No description provided for @categoryBody.
  ///
  /// In es, this message translates to:
  /// **'Cuerpo Humano'**
  String get categoryBody;

  /// No description provided for @categoryNature.
  ///
  /// In es, this message translates to:
  /// **'Naturaleza'**
  String get categoryNature;

  /// No description provided for @categoryTechnology.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get categoryTechnology;

  /// No description provided for @categoryEmotions.
  ///
  /// In es, this message translates to:
  /// **'Emociones'**
  String get categoryEmotions;

  /// No description provided for @categoryTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get categoryTransport;

  /// No description provided for @categoryMusic.
  ///
  /// In es, this message translates to:
  /// **'Música'**
  String get categoryMusic;

  /// No description provided for @categoryFood.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get categoryFood;

  /// No description provided for @categoryClothing.
  ///
  /// In es, this message translates to:
  /// **'Ropa'**
  String get categoryClothing;

  /// No description provided for @categorySpace.
  ///
  /// In es, this message translates to:
  /// **'Espacio'**
  String get categorySpace;

  /// No description provided for @categorySchool.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get categorySchool;

  /// No description provided for @guideScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Guía de Usuario'**
  String get guideScreenTitle;

  /// No description provided for @guideHowToPlayTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo jugar'**
  String get guideHowToPlayTitle;

  /// No description provided for @guideHowToPlayBody.
  ///
  /// In es, this message translates to:
  /// **'Arrastra el dedo desde la primera hasta la última letra de una palabra oculta en la grilla. Puede estar en horizontal, vertical o diagonal, y hacia adelante o hacia atrás una vez que desbloquees esa dificultad. Encuentra todas las palabras de la lista para completar el nivel.'**
  String get guideHowToPlayBody;

  /// No description provided for @guideWorldsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mundos infinitos'**
  String get guideWorldsTitle;

  /// No description provided for @guideWorldsBody.
  ///
  /// In es, this message translates to:
  /// **'Cada mundo agrupa 8 niveles con un mismo tema. Al acercarte al final de tus mundos desbloqueados, la app genera el siguiente automáticamente: nuevo tema, grilla más grande y más palabras. Nunca se acaban.'**
  String get guideWorldsBody;

  /// No description provided for @guideLangThemeTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma y tema'**
  String get guideLangThemeTitle;

  /// No description provided for @guideLangThemeBody.
  ///
  /// In es, this message translates to:
  /// **'Cambia el idioma (Español/English) y el tema (claro/oscuro) en cualquier momento desde Ajustes. Tus letras siempre se mantienen legibles en ambos modos.'**
  String get guideLangThemeBody;

  /// No description provided for @guideUpdatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get guideUpdatesTitle;

  /// No description provided for @guideUpdatesBody.
  ///
  /// In es, this message translates to:
  /// **'La app revisa GitHub Releases al abrirse. Si hay una versión nueva, te avisa con un botón para descargarla e instalarla (Android) o abrir la página de descarga (iOS).'**
  String get guideUpdatesBody;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsScreenTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get settingsLanguageSpanish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} (build {build})'**
  String settingsAboutVersion(String version, String build);

  /// No description provided for @settingsAboutGenesis.
  ///
  /// In es, this message translates to:
  /// **'Aplicación creada el {date}'**
  String settingsAboutGenesis(String date);

  /// No description provided for @settingsCheckUpdates.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualizaciones'**
  String get settingsCheckUpdates;

  /// No description provided for @statsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsTitle;

  /// No description provided for @statsWordsFound.
  ///
  /// In es, this message translates to:
  /// **'Palabras encontradas'**
  String get statsWordsFound;

  /// No description provided for @statsLevelsCompleted.
  ///
  /// In es, this message translates to:
  /// **'Niveles completados'**
  String get statsLevelsCompleted;

  /// No description provided for @statsStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha actual'**
  String get statsStreak;

  /// No description provided for @statsStreakDays.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String statsStreakDays(int days);

  /// No description provided for @statsBestStreak.
  ///
  /// In es, this message translates to:
  /// **'Mejor racha: {days} días'**
  String statsBestStreak(int days);

  /// No description provided for @statsPlayTime.
  ///
  /// In es, this message translates to:
  /// **'Tiempo jugado'**
  String get statsPlayTime;

  /// No description provided for @settingsResetProgress.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar progreso'**
  String get settingsResetProgress;

  /// No description provided for @settingsResetProgressConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres borrar todo tu progreso? Esta acción no se puede deshacer.'**
  String get settingsResetProgressConfirm;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualización disponible'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In es, this message translates to:
  /// **'Hay una nueva versión ({version}) de Letraverse disponible.'**
  String updateAvailableBody(String version);

  /// No description provided for @updateDownloadInstall.
  ///
  /// In es, this message translates to:
  /// **'Descargar e instalar'**
  String get updateDownloadInstall;

  /// No description provided for @updateOpenReleasePage.
  ///
  /// In es, this message translates to:
  /// **'Abrir página de descarga'**
  String get updateOpenReleasePage;

  /// No description provided for @updateLater.
  ///
  /// In es, this message translates to:
  /// **'Más tarde'**
  String get updateLater;

  /// No description provided for @updateDownloading.
  ///
  /// In es, this message translates to:
  /// **'Descargando actualización…'**
  String get updateDownloading;

  /// No description provided for @updateUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes la última versión'**
  String get updateUpToDate;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;

  /// No description provided for @footerCredit.
  ///
  /// In es, this message translates to:
  /// **'Creado por: Pedro Espinal — Todos los derechos reservados © 2026'**
  String get footerCredit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
