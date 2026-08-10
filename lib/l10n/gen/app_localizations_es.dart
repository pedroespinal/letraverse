// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'HiddenWords';

  @override
  String get appTagline => 'Sopa de Letras Infinita';

  @override
  String get navPlay => 'Jugar';

  @override
  String get navWorlds => 'Mundos';

  @override
  String get navGuide => 'Guía';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get playScreenTimer => 'Tiempo';

  @override
  String playScreenWordsFound(int found, int total) {
    return '$found/$total palabras';
  }

  @override
  String playScreenWorldLabel(int n) {
    return 'Mundo $n';
  }

  @override
  String playScreenLevelLabel(int n, int total) {
    return 'Nivel $n de $total';
  }

  @override
  String get playScreenLevelComplete => '¡Nivel completado!';

  @override
  String get playScreenNextLevel => 'Siguiente nivel';

  @override
  String playScreenNewWorldUnlocked(String name) {
    return '¡Nuevo mundo desbloqueado: $name!';
  }

  @override
  String get playScreenShuffle => 'Mezclar letras señuelo';

  @override
  String get playScreenNoActiveLevel => 'No hay un nivel activo';

  @override
  String get playScreenStartPlaying => 'Empezar a jugar';

  @override
  String get worldsScreenTitle => 'Mundos Infinitos';

  @override
  String get worldsScreenSubtitle =>
      'Cada mundo trae un tema nuevo. Al terminar uno, el motor genera el siguiente automáticamente.';

  @override
  String get worldsScreenLocked => 'Bloqueado';

  @override
  String get worldsScreenCompleted => 'Completado';

  @override
  String get worldsScreenInProgress => 'En progreso';

  @override
  String worldsScreenLevelsDone(int done, int total) {
    return '$done/$total niveles';
  }

  @override
  String get worldsScreenPlay => 'Jugar';

  @override
  String get categoryAnimals => 'Animales';

  @override
  String get categoryFruits => 'Frutas';

  @override
  String get categoryColors => 'Colores';

  @override
  String get categoryCountries => 'Países';

  @override
  String get categorySports => 'Deportes';

  @override
  String get categoryProfessions => 'Profesiones';

  @override
  String get categoryBody => 'Cuerpo Humano';

  @override
  String get categoryNature => 'Naturaleza';

  @override
  String get categoryTechnology => 'Tecnología';

  @override
  String get categoryEmotions => 'Emociones';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryMusic => 'Música';

  @override
  String get categoryFood => 'Comida';

  @override
  String get categoryClothing => 'Ropa';

  @override
  String get categorySpace => 'Espacio';

  @override
  String get categorySchool => 'Escuela';

  @override
  String get guideScreenTitle => 'Guía de Usuario';

  @override
  String get guideHowToPlayTitle => 'Cómo jugar';

  @override
  String get guideHowToPlayBody =>
      'Arrastra el dedo desde la primera hasta la última letra de una palabra oculta en la grilla. Puede estar en horizontal, vertical o diagonal, y hacia adelante o hacia atrás una vez que desbloquees esa dificultad. Encuentra todas las palabras de la lista para completar el nivel.';

  @override
  String get guideWorldsTitle => 'Mundos infinitos';

  @override
  String get guideWorldsBody =>
      'Cada mundo agrupa 8 niveles con un mismo tema. Al acercarte al final de tus mundos desbloqueados, la app genera el siguiente automáticamente: nuevo tema, grilla más grande y más palabras. Nunca se acaban.';

  @override
  String get guideLangThemeTitle => 'Idioma y tema';

  @override
  String get guideLangThemeBody =>
      'Cambia el idioma (Español/English) y el tema (claro/oscuro) en cualquier momento desde Ajustes. Tus letras siempre se mantienen legibles en ambos modos.';

  @override
  String get guideUpdatesTitle => 'Actualizaciones';

  @override
  String get guideUpdatesBody =>
      'La app revisa GitHub Releases al abrirse. Si hay una versión nueva, te avisa con un botón para descargarla e instalarla (Android) o abrir la página de descarga (iOS).';

  @override
  String get settingsScreenTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSystem => 'Automático';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeSystem => 'Automático';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String settingsAboutVersion(String version, String build) {
    return 'Versión $version (build $build)';
  }

  @override
  String settingsAboutGenesis(String date) {
    return 'Aplicación creada el $date';
  }

  @override
  String get settingsCheckUpdates => 'Buscar actualizaciones';

  @override
  String get settingsResetProgress => 'Reiniciar progreso';

  @override
  String get settingsResetProgressConfirm =>
      '¿Seguro que quieres borrar todo tu progreso? Esta acción no se puede deshacer.';

  @override
  String get updateAvailableTitle => 'Actualización disponible';

  @override
  String updateAvailableBody(String version) {
    return 'Hay una nueva versión ($version) de HiddenWords disponible.';
  }

  @override
  String get updateDownloadInstall => 'Descargar e instalar';

  @override
  String get updateOpenReleasePage => 'Abrir página de descarga';

  @override
  String get updateLater => 'Más tarde';

  @override
  String get updateDownloading => 'Descargando actualización…';

  @override
  String get updateUpToDate => 'Ya tienes la última versión';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get footerCredit =>
      'Creado por: Pedro Espinal — Todos los derechos reservados © 2026';
}
