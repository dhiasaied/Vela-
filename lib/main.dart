import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/store.dart';
import 'screens/splash_screen.dart';
import 'theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(VelaApp(theme: ThemeController(), store: AppStore()));
}

class VelaApp extends StatelessWidget {
  final ThemeController theme;
  final AppStore store;
  const VelaApp({super.key, required this.theme, required this.store});

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: theme,
      child: StoreScope(
        store: store,
        child: ListenableBuilder(
          listenable: theme,
          builder: (context, _) => MaterialApp(
            title: 'Vela',
            debugShowCheckedModeBanner: false,
            theme: theme.buildTheme(Brightness.light),
            darkTheme: theme.buildTheme(Brightness.dark),
            themeMode: theme.mode,
            themeAnimationDuration: const Duration(milliseconds: 450),
            themeAnimationCurve: Curves.easeOutCubic,
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
