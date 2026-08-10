import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-facing settings (theme, language) that must survive app
/// restarts but never need syncing anywhere else.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'settings.theme_mode';
  static const _localeKey = 'settings.locale_code';

  ThemeMode get themeMode {
    switch (_prefs.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _prefs.setString(_themeKey, mode.name);
  }

  /// Null means "follow the device locale".
  Locale? get locale {
    final code = _prefs.getString(_localeKey);
    if (code == null || code == 'system') return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale? locale) {
    if (locale == null) return _prefs.setString(_localeKey, 'system');
    return _prefs.setString(_localeKey, locale.languageCode);
  }
}
