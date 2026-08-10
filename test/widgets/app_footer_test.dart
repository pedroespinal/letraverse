import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:letraverse/l10n/gen/app_localizations.dart';
import 'package:letraverse/widgets/app_footer.dart';

void main() {
  Future<void> pumpFooterWithBottomInset(WidgetTester tester, double bottomInset) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(viewPadding: EdgeInsets.only(bottom: bottomInset)),
            child: const Scaffold(
              body: Align(alignment: Alignment.bottomCenter, child: AppFooter()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('adds no extra bottom padding when there is no system inset (3-button nav)', (tester) async {
    await pumpFooterWithBottomInset(tester, 0);
    final padding = tester.widget<Padding>(
      find.descendant(of: find.byType(AppFooter), matching: find.byType(Padding)).first,
    );
    expect(padding.padding, const EdgeInsets.fromLTRB(12, 4, 12, 4));
  });

  testWidgets('grows bottom padding to clear the gesture pill inset', (tester) async {
    await pumpFooterWithBottomInset(tester, 34);
    final padding = tester.widget<Padding>(
      find.descendant(of: find.byType(AppFooter), matching: find.byType(Padding)).first,
    );
    expect(padding.padding, const EdgeInsets.fromLTRB(12, 4, 12, 38));
  });
}
