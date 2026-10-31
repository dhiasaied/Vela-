import 'package:flutter/material.dart';

/// A named accent palette the user can pick from.
class AccentPreset {
  final String name;
  final Color primary;
  final Color secondary;
  const AccentPreset(this.name, this.primary, this.secondary);
}

const accentPresets = <AccentPreset>[
  AccentPreset('Ember', Color(0xFFFF6A2B), Color(0xFFFFB347)),
  AccentPreset('Violet', Color(0xFF7C4DFF), Color(0xFFB388FF)),
  AccentPreset('Ocean', Color(0xFF1E88E5), Color(0xFF4DD0E1)),
  AccentPreset('Emerald', Color(0xFF10B981), Color(0xFF84E1BC)),
  AccentPreset('Rose', Color(0xFFE91E63), Color(0xFFFF8A80)),
  AccentPreset('Gold', Color(0xFFD4A017), Color(0xFFFFE08A)),
  AccentPreset('Graphite', Color(0xFF37474F), Color(0xFF90A4AE)),
  AccentPreset('Lime', Color(0xFF65A30D), Color(0xFFD9F99D)),
];

/// Holds the app-wide colour and brightness state and notifies listeners
/// so every screen re-themes instantly.
class ThemeController extends ChangeNotifier {
  Color _primary = accentPresets.first.primary;
  Color _secondary = accentPresets.first.secondary;
  ThemeMode _mode = ThemeMode.light;

  Color get primary => _primary;
  Color get secondary => _secondary;
  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void applyPreset(AccentPreset p) => setColors(p.primary, p.secondary);

  void setColors(Color primary, [Color? secondary]) {
    _primary = primary;
    _secondary = secondary ?? _derivedSecondary(primary);
    notifyListeners();
  }

  void toggleDark(bool value) {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  static Color _derivedSecondary(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withHue((hsl.hue + 28) % 360)
        .withLightness((hsl.lightness + 0.18).clamp(0.0, 0.85))
        .toColor();
  }

  ThemeData buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
    ).copyWith(
      primary: _primary,
      secondary: _secondary,
      surface: dark ? const Color(0xFF14151A) : Colors.white,
      onSurface: dark ? Colors.white : const Color(0xFF16171D),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF0C0D11) : const Color(0xFFF5F5F8),
      fontFamily: 'Roboto',
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
      ),
      sliderTheme: const SliderThemeData(trackHeight: 10),
    );
  }
}

/// Exposes the [ThemeController] down the tree.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({super.key, required ThemeController controller, required super.child})
      : super(notifier: controller);

  static ThemeController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.notifier!;
}

/// Handy colour helpers used across widgets.
extension VelaColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get card => isDark ? const Color(0xFF1A1B22) : Colors.white;
  Color get muted => isDark ? Colors.white54 : const Color(0xFF8A8B96);
  Color get line => isDark ? Colors.white10 : const Color(0xFFECECF1);
}
