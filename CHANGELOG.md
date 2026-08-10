# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/). Versionado: `MAJOR.MINOR.PATCH+BUILD`.

## [1.1.0+7] - 2026-08-10
### Fixed
- `UpdateChecker.isNewer` ahora compara también el build number, no solo major.minor.patch. Antes, dos releases con la misma versión "1.1.0" pero distinto build (que es exactamente lo que produce `build_release.ps1` por defecto) se consideraban iguales y el chequeo de actualizaciones nunca notificaba nada.
- `scripts/build_release.ps1` ahora sugiere taguear con el build number incluido (`v$maj.$min.$pat+$build`), ya que un tag sin build nunca activaría el aviso de "hay una actualización" para quien ya tenga esa misma versión instalada.

## [1.1.0+6] - 2026-08-10
### Added
- Tests de `PlayController` (`test/features/play_controller_test.dart`): estado inicial, reanudar progreso, cargar puzzle, encontrar palabras (directo/invertido/sin match), completar nivel con stats+progreso, avanzar de nivel, desbloqueo de mundo nuevo, salto directo a nivel.
- Tests de `UpdateChecker` (`test/features/update_checker_test.dart`) para la comparación de versiones semver contra GitHub Releases.

### Changed
- `UpdateChecker._isNewer`/`_parseSemver` pasan a ser `isNewer`/`parseSemver` con `@visibleForTesting`, para poder testearlos directamente.

### Removed
- Dependencia `integration_test` (declarada pero nunca usada).

## [1.1.0+5] - 2026-08-10
### Added
- Golden tests (`test/golden/`) para la pantalla de juego y la de ajustes/estadísticas, como red de seguridad ante regresiones visuales. Corren como gate obligatorio en `scripts/build_release.ps1` (máquina de build canónica); excluidos del workflow de GitHub Actions vía el tag `golden`, ya que esos runners no garantizan rasterizado idéntico al de la máquina local.

### Changed
- `flutter_lints` actualizado de 5.0.0 a 6.0.0; corregido el único aviso nuevo (`unnecessary_underscores` en `settings_screen.dart`).

### Audited
- Auditoría completa: `flutter analyze` y `flutter test` sin hallazgos, build de verificación exitoso, paridad de claves ES/EN confirmada (87/87), bancos de palabras verificados contra el changelog (16 categorías × 60 palabras, sin duplicados), y credenciales de firma confirmadas fuera de git. `package_info_plus` 10.x y el resto de dependencias directas permanecen fijadas: requieren Dart SDK ≥3.10, mientras el SDK de Flutter usado (3.35.5) trae Dart 3.9.2.

## [1.1.0] - 2026-08-10
### Added
- Bancos de palabras ampliados de 30 a 60 palabras por categoría (16 categorías, ES/EN).
- Feedback háptico y de sonido (tonos generados localmente, sin assets externos) al encontrar una palabra o completar un nivel.
- Accesibilidad: selección alternativa tocando la primera y última letra (sin necesidad de arrastrar), etiquetas Semantics en cada celda para TalkBack/VoiceOver, y una pista visible de cómo seleccionar.
- Estadísticas: palabras encontradas, niveles completados, racha diaria (con mejor racha) y tiempo total jugado, visibles en Ajustes.
- Política de privacidad bilingüe (`PRIVACY_POLICY.md`), enlazada desde Ajustes.
- Capturas de pantalla reales en `store/screenshots/` para futuras publicaciones en tiendas.

### Changed
- Renombrado del proyecto de "HiddenWords" a **Letraverse**: paquete Dart, `applicationId`/bundle ID, y repositorio de GitHub actualizados en consecuencia.

## [1.0.0] - 2026-08-10
### Added
- Motor de generación procedural de mundos infinitos (`WorldGenerator` + `GridPlacer`), determinista por semilla.
- 16 categorías de palabras bilingües (ES/EN), 30 palabras cada una.
- Bilingüe (Español/English), con selector manual o automático.
- Tema claro (Menta Fresca) y oscuro (Tinta Nocturna), contraste WCAG ≥4.5:1.
- Pantallas: Jugar, Mundos, Guía, Ajustes/Acerca de.
- Progreso local con Hive; sin backend.
- Chequeo de actualizaciones contra GitHub Releases, con descarga + instalación directa de APK en Android.
- Ícono e identidad visual propios, splash screen adaptativa.
- Footer de créditos con ajuste automático a la barra de gestos del sistema.
- Firma digital propia (`upload-keystore.jks`) y auditoría obligatoria (`analyze` + `test`) antes de compilar.
- Fecha de creación de la app registrada de forma inmutable (`app_genesis.dart` + tag `genesis`).
