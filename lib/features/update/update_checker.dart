import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  const UpdateInfo({required this.version, required this.releaseUrl, this.apkAssetUrl});
  final String version;
  final String releaseUrl;
  final String? apkAssetUrl;
}

/// Checks GitHub Releases for a newer published version. Fails silently
/// (returns null) on any network/parsing problem — a missed update check
/// must never crash or block the app, especially before the repo exists.
class UpdateChecker {
  static const String owner = 'pedroespinal';
  static const String repo = 'letraverse';
  static const String _apiUrl = 'https://api.github.com/repos/$owner/$repo/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = (json['tag_name'] as String?)?.trim();
      if (tag == null || tag.isEmpty) return null;

      final packageInfo = await PackageInfo.fromPlatform();
      if (!isNewer(tag, packageInfo.version, packageInfo.buildNumber)) return null;

      String? apkUrl;
      for (final asset in (json['assets'] as List<dynamic>? ?? const [])) {
        final name = (asset['name'] as String?)?.toLowerCase() ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      return UpdateInfo(
        version: tag,
        releaseUrl: json['html_url'] as String? ?? 'https://github.com/$owner/$repo/releases',
        apkAssetUrl: apkUrl,
      );
    } catch (_) {
      return null;
    }
  }

  /// Compares `tag` (a GitHub release tag, e.g. "v1.1.0+6") against the
  /// installed `currentVersion`/`currentBuildNumber` (from PackageInfo).
  /// Major.minor.patch is compared first; if those tie, the build number
  /// breaks the tie. That build-number fallback matters because
  /// scripts/build_release.ps1 bumps only the build number by default —
  /// most releases share the same major.minor.patch, so without it this
  /// check would never notice a new build.
  @visibleForTesting
  bool isNewer(String tag, String currentVersion, String currentBuildNumber) {
    final tagVersion = tag.startsWith('v') ? tag.substring(1) : tag;
    final incoming = parseVersion(tagVersion);
    final current = parseVersion('$currentVersion+$currentBuildNumber');
    for (var i = 0; i < 3; i++) {
      if (incoming.semver[i] != current.semver[i]) {
        return incoming.semver[i] > current.semver[i];
      }
    }
    return incoming.build > current.build;
  }

  @visibleForTesting
  List<int> parseSemver(String v) {
    final parts = v.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }

  /// Splits a `MAJOR.MINOR.PATCH+BUILD` string (the "+BUILD" suffix is
  /// optional and defaults to 0) the same way pubspec.yaml's `version:`
  /// field is formatted.
  @visibleForTesting
  ({List<int> semver, int build}) parseVersion(String v) {
    final parts = v.split('+');
    final semver = parseSemver(parts[0]);
    final build = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return (semver: semver, build: build);
  }
}

final updateCheckerProvider = Provider<UpdateChecker>((ref) => UpdateChecker());
