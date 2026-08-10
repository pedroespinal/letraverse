# Letraverse — Sopa de Letras Infinita

Sopa de letras bilingüe (Español/English) para Android e iOS con un motor procedural que genera mundos temáticos nuevos automáticamente, sin conexión ni costo por generación. / A bilingual (Spanish/English) word-search game for Android and iOS with a procedural engine that generates new themed worlds automatically, offline and at no per-generation cost.

**Creado por: Pedro Espinal — Todos los derechos reservados © 2026**

---

## Español

### Qué es
Cada 8 niveles forman un **mundo** temático (animales, países, tecnología, emociones, etc.). Al acercarte al final de tus mundos desbloqueados, el motor genera el siguiente automáticamente — dificultad, tamaño de grilla y palabras incluidos — de forma determinista (mismo índice de mundo, siempre el mismo mundo).

### Características
- Bilingüe (ES/EN), con selector manual o automático según el idioma del dispositivo.
- Modo claro y oscuro, paleta verificada con contraste WCAG ≥4.5:1.
- Progreso guardado localmente (Hive), nada se sube a ningún servidor.
- Chequeo de actualizaciones vía GitHub Releases, con descarga e instalación directa del APK en Android.
- Auditoría obligatoria (`flutter analyze` + `flutter test`) antes de cada compilación de release — ver [`scripts/build_release.ps1`](scripts/build_release.ps1).

### Correr el proyecto
```bash
flutter pub get
flutter run
```

### Compilar un release (audita, versiona y firma automáticamente)
```powershell
./scripts/build_release.ps1            # incrementa solo el build number
./scripts/build_release.ps1 -Patch     # incrementa patch + build
./scripts/build_release.ps1 -Minor     # incrementa minor + build
./scripts/build_release.ps1 -Major     # incrementa major + build
```

### Estructura
```
lib/
  core/        theming, i18n, providers, constantes (incluye la fecha de creación)
  data/        repositorios (progreso, ajustes)
  domain/      motor de generación de mundos y grillas (WorldGenerator, GridPlacer)
  features/    pantallas: jugar, mundos, guía, ajustes, actualizaciones
assets/wordbanks/  bancos de palabras bilingües por categoría
scripts/           auditoría + versionado + build de release
```

Ver la guía de usuario completa en [`USER_GUIDE.md`](USER_GUIDE.md).

---

## English

### What it is
Every 8 levels form a themed **world** (animals, countries, technology, emotions, etc.). As you approach the end of your unlocked worlds, the engine generates the next one automatically — difficulty, grid size and words included — deterministically (same world index always rebuilds the same world).

### Features
- Bilingual (ES/EN), automatic (device locale) or manual language selection.
- Light and dark themes, palette verified for WCAG contrast ≥4.5:1.
- Progress saved locally (Hive) — nothing is uploaded anywhere.
- Update check via GitHub Releases, with direct APK download + install on Android.
- Mandatory audit (`flutter analyze` + `flutter test`) before every release build — see [`scripts/build_release.ps1`](scripts/build_release.ps1).

### Running the project
```bash
flutter pub get
flutter run
```

See the full user guide in [`USER_GUIDE.md`](USER_GUIDE.md) and the [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md) (the app collects no personal data — everything is stored on-device).

---

## Firma / Signing
El release se firma con un keystore propio (`android/upload-keystore.jks`, no versionado). **Guarda una copia de ese archivo y de `android/key.properties` en un lugar seguro fuera de este repo** — sin ellos no se pueden publicar actualizaciones firmadas con la misma identidad.

## Constancia de creación / Genesis record
La fecha de creación de la app está fijada en [`lib/core/app_genesis.dart`](lib/core/app_genesis.dart) y respaldada por el primer commit/tag (`genesis`) de este repositorio.
