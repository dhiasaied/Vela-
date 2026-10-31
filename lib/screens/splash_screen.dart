import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';
import '../widgets/package_box.dart';
import 'root_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
    ..forward().whenComplete(_go);

  void _go() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, a, __) => const RootShell(),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 1.06, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
      ),
    ));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final drop = CurvedAnimation(parent: _c, curve: const Interval(0, .45, curve: Curves.elasticOut));
    final text = CurvedAnimation(parent: _c, curve: const Interval(.35, .7, curve: Curves.easeOutCubic));
    final bar = CurvedAnimation(parent: _c, curve: const Interval(.5, 1, curve: Curves.easeInOutCubic));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, Color.lerp(cs.primary, cs.secondary, .6)!],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Column(mainAxisSize: MainAxisSize.min, children: [
              Transform.translate(
                offset: Offset(0, -60 * (1 - drop.value)),
                child: Transform.scale(
                  scale: .4 + .6 * drop.value,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 30, offset: const Offset(0, 14))],
                    ),
                    child: const PackageBox(size: 72),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Opacity(
                opacity: text.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - text.value)),
                  child: const Column(children: [
                    Text('vela',
                        style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                    SizedBox(height: 4),
                    Text('Every parcel, in real time', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                ),
              ),
              const SizedBox(height: 36),
              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: bar.value,
                  child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
