import 'package:flutter_test/flutter_test.dart';
import 'package:vela/data/store.dart';
import 'package:vela/main.dart';
import 'package:vela/theme/theme_controller.dart';

void main() {
  testWidgets('splash leads to home and theme colour can change', (tester) async {
    final theme = ThemeController();
    await tester.pumpWidget(VelaApp(theme: theme, store: AppStore()));
    expect(find.text('vela'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('My Shipping'), findsOneWidget);

    theme.applyPreset(accentPresets[2]);
    await tester.pump(const Duration(milliseconds: 600));
    expect(theme.primary, accentPresets[2].primary);
  });
}
