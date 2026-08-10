import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';

/// Persistent copyright strip shown at the very bottom of every screen.
/// Uses [MediaQuery.viewPadding] (not a fixed inset) so it always clears
/// the system gesture pill / 3-button nav bar / iOS home indicator,
/// regardless of device or edge-to-edge mode.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: scheme.surface,
      padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + bottomInset),
      child: Text(
        l10n.footerCredit,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
