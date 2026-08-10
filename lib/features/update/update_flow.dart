import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/gen/app_localizations.dart';
import 'update_checker.dart';

/// Runs a GitHub Releases check and, if a newer version exists, shows the
/// bilingual "update available" dialog. On Android, offers to download the
/// APK asset straight from the release and hand it to the system installer;
/// on iOS (no ad-hoc signing available) it opens the release page instead,
/// since a raw IPA cannot be side-installed without TestFlight/Apple certs.
Future<void> presentUpdateIfAvailable(
  BuildContext context,
  WidgetRef ref, {
  bool silentWhenUpToDate = true,
}) async {
  final checker = ref.read(updateCheckerProvider);
  final info = await checker.checkForUpdate();
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context)!;
  if (info == null) {
    if (!silentWhenUpToDate) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.updateUpToDate)));
    }
    return;
  }

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Text(l10n.updateAvailableBody(info.version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.updateLater),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            if (Platform.isAndroid && info.apkAssetUrl != null) {
              await _downloadAndInstall(context, l10n, info.apkAssetUrl!);
            } else {
              await launchUrl(Uri.parse(info.releaseUrl), mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            Platform.isAndroid && info.apkAssetUrl != null
                ? l10n.updateDownloadInstall
                : l10n.updateOpenReleasePage,
          ),
        ),
      ],
    ),
  );
}

Future<void> _downloadAndInstall(BuildContext context, AppLocalizations l10n, String apkUrl) async {
  unawaited(showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(l10n.updateDownloading)),
        ],
      ),
    ),
  ));

  try {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/letraverse_update.apk';
    await Dio().download(apkUrl, filePath);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    await OpenFilex.open(filePath);
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
