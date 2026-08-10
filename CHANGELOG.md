# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/). Versionado: `MAJOR.MINOR.PATCH+BUILD`.

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
