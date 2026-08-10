<#
.SYNOPSIS
  Audits, versions, and builds a Letraverse release. Never skips the audit:
  if analyze or test fails, nothing is compiled.

.PARAMETER Major
  Bump the major version (resets minor/patch to 0).
.PARAMETER Minor
  Bump the minor version (resets patch to 0).
.PARAMETER Patch
  Bump the patch version.
  (With none of the three, only the build number advances.)
#>
param(
    [switch]$Major,
    [switch]$Minor,
    [switch]$Patch
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$env:PATH = "C:\src\flutter\bin;$env:PATH"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "== $msg ==" -ForegroundColor Cyan
}

Write-Step "1/5 Auditoria: flutter analyze"
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "Auditoria fallida (analyze). No se compila nada." -ForegroundColor Red
    exit 1
}

Write-Step "2/5 Auditoria: flutter test"
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Auditoria fallida (test). No se compila nada." -ForegroundColor Red
    exit 1
}

Write-Step "3/5 Incrementando version"
$pubspecPath = Join-Path $root "pubspec.yaml"
$content = Get-Content $pubspecPath -Raw
if ($content -notmatch 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    Write-Host "No se pudo leer 'version:' en pubspec.yaml" -ForegroundColor Red
    exit 1
}
$maj = [int]$Matches[1]; $min = [int]$Matches[2]; $pat = [int]$Matches[3]; $build = [int]$Matches[4]

if ($Major) { $maj++; $min = 0; $pat = 0 }
elseif ($Minor) { $min++; $pat = 0 }
elseif ($Patch) { $pat++ }
$build++

$newVersion = "$maj.$min.$pat+$build"
$newContent = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersion"
Set-Content -Path $pubspecPath -Value $newContent
Write-Host "Nueva version: $newVersion"

Write-Step "4/5 Compilando APK release"
flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo al compilar el APK." -ForegroundColor Red
    exit 1
}

Write-Step "5/5 Compilando App Bundle release"
flutter build appbundle --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo al compilar el App Bundle." -ForegroundColor Red
    exit 1
}

Write-Step "6/6 Archivando release versionado"
$releaseDir = Join-Path $root "releases\v$maj.$min.$pat+$build"
New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null
Copy-Item "build\app\outputs\flutter-apk\app-release.apk" (Join-Path $releaseDir "letraverse-v$maj.$min.$pat+$build.apk") -Force
Copy-Item "build\app\outputs\bundle\release\app-release.aab" (Join-Path $releaseDir "letraverse-v$maj.$min.$pat+$build.aab") -Force

Write-Host ""
Write-Host "Listo. Version $newVersion compilada y firmada." -ForegroundColor Green
Write-Host "Archivo versionado en: $releaseDir"

Write-Step "7/7 Publicando en GitHub"
# Standing rule: every build_release.ps1 run pushes to GitHub -- no
# per-run confirmation. The tag always carries the build number (not just
# major.minor.patch): UpdateChecker.isNewer compares both, so a tag
# without it would never notify anyone already on this major.minor.patch.
$tag = "v$maj.$min.$pat+$build"

git add -A
git diff --cached --quiet
$hasStagedChanges = ($LASTEXITCODE -ne 0)
if ($hasStagedChanges) {
    git commit -m "chore: bump version to $newVersion"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Fallo al hacer commit. Publicacion abortada -- resuelve esto a mano." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Nada nuevo que commitear (aparte de lo ya commiteado)." -ForegroundColor Yellow
}

git tag $tag
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo al crear el tag $tag (¿ya existe?). Publicacion abortada." -ForegroundColor Red
    exit 1
}

git push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo al pushear main. El tag $tag quedo creado localmente pero no se publico." -ForegroundColor Red
    exit 1
}

git push origin $tag
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fallo al pushear el tag $tag." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Publicado: commit + tag $tag pusheados a origin/main." -ForegroundColor Green
Write-Host "Esto dispara el workflow de GitHub Actions que firma y publica el Release." -ForegroundColor Green
