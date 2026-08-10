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
      if (!isNewer(tag, packageInfo.version)) return null;

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

  @visibleForTesting
  bool isNewer(String tag, String currentVersion) {
    final tagVersion = tag.startsWith('v') ? tag.substring(1) : tag;
    final incoming = parseSemver(tagVersion);
    final current = parseSemver(currentVersion);
    for (var i = 0; i < 3; i++) {
      if (incoming[i] != current[i]) return incoming[i] > current[i];
    }
    return false;
  }

  @visibleForTesting
  List<int> parseSemver(String v) {
    final parts = v.split('.');
    return List.generate(3, (i) => i < parts.length ? (int.tryParse(parts[i]) ?? 0) : 0);
  }
}

final updateCheckerProvider = Provider<UpdateChecker>((ref) => UpdateChecker());
