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

Write-Host ""
Write-Host "Listo. Version $newVersion compilada y firmada." -ForegroundColor Green
Write-Host "APK:    build\app\outputs\flutter-apk\app-release.apk"
Write-Host "AAB:    build\app\outputs\bundle\release\app-release.aab"
Write-Host ""
Write-Host "Siguiente paso sugerido:"
Write-Host "  git add pubspec.yaml && git commit -m 'chore: bump version to $newVersion'"
Write-Host "  git tag v$maj.$min.$pat && git push origin main --tags"
