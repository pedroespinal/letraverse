import 'package:flutter/material.dart';

import '../../l10n/gen/app_localizations.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = <(IconData, String, String)>[
      (Icons.touch_app_outlined, l10n.guideHowToPlayTitle, l10n.guideHowToPlayBody),
      (Icons.public_outlined, l10n.guideWorldsTitle, l10n.guideWorldsBody),
      (Icons.palette_outlined, l10n.guideLangThemeTitle, l10n.guideLangThemeBody),
      (Icons.system_update_alt_outlined, l10n.guideUpdatesTitle, l10n.guideUpdatesBody),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l10n.guideScreenTitle, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          for (final (icon, title, body) in sections)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
