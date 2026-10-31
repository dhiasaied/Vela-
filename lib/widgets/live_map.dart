import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// A stylised, fully offline city map with a live courier.
///
/// Simulated GPS fixes arrive every [fixInterval]; between fixes the marker is
/// interpolated along the route and rotated to its bearing, so it glides
/// instead of jumping.
class LiveMap extends StatefulWidget {
  final ValueNotifier<double> progress;
  final String courierLabel;
  final bool running;
  final Duration fixInterval;
  const LiveMap({
    super.key,
    required this.progress,
    required this.courierLabel,
    this.running = true,
    this.fixInterval = const Duration(milliseconds: 2200),
  });

  @override
  State<LiveMap> createState() => LiveMapState();
}

class LiveMapState extends State<LiveMap> with TickerProviderStateMixin {
  late final AnimationController _move =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  final _transform = TransformationController();
  late final AnimationController _camera =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  Animation<Matrix4>? _cameraAnim;
  Timer? _gps;
  double _from = 0, _to = 0;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.progress.value;
    _move.addListener(() {
      widget.progress.value = ui.lerpDouble(_from, _to, Curves.easeInOutSine.transform(_move.value))!;
    });
    _camera.addListener(() {
      if (_cameraAnim != null) _transform.value = _cameraAnim!.value;
    });
    if (widget.running) _startGps();
  }

  void _startGps() {
    _gps = Timer.periodic(widget.fixInterval, (_) {
      if (_to >= 1) {
        _gps?.cancel();
        return;
      }
      _from = widget.progress.value;
      _to = math.min(1, _to + .018 + math.Random().nextDouble() * .014);
      _move.forward(from: 0);
    });
  }

  /// Smoothly resets pan/zoom.
  void recenter() {
    _cameraAnim = Matrix4Tween(begin: _transform.value, end: Matrix4.identity())
        .animate(CurvedAnimation(parent: _camera, curve: Curves.easeOutCubic));
    _camera.forward(from: 0);
  }

  @override
  void dispose() {
    _gps?.cancel();
    _move.dispose();
    _pulse.dispose();
    _camera.dispose();
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transform,
      minScale: 1,
      maxScale: 3.5,
      child: CustomPaint(
        size: Size.infinite,
        painter: _MapPainter(
          progress: widget.progress,
          pulse: _pulse,
          primary: context.cs.primary,
          secondary: context.cs.secondary,
          dark: context.isDark,
          label: widget.courierLabel,
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final ValueNotifier<double> progress;
  final Animation<double> pulse;
  final Color primary, secondary;
  final bool dark;
  final String label;

  _MapPainter({
    required this.progress,
    required this.pulse,
    required this.primary,
    required this.secondary,
    required this.dark,
    required this.label,
  }) : super(repaint: Listenable.merge([progress, pulse]));

  static const _route = [
    Offset(.14, .44),
    Offset(.24, .41),
    Offset(.34, .34),
    Offset(.48, .39),
    Offset(.58, .30),
    Offset(.64, .22),
    Offset(.84, .17),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset n) => Offset(n.dx * size.width, n.dy * size.height);

    final bg = dark ? const Color(0xFF181A21) : const Color(0xFFEDEFF3);
    final block = dark ? const Color(0xFF1F222B) : const Color(0xFFF7F8FA);
    final road = dark ? const Color(0xFF2B2F3A) : Colors.white;
    final major = dark ? const Color(0xFF353A47) : const Color(0xFFFFFFFF);
    final park = dark ? const Color(0xFF1C2B23) : const Color(0xFFD5ECD2);
    final water = dark ? const Color(0xFF172636) : const Color(0xFFC9E2F6);
    final text = dark ? Colors.white38 : const Color(0xFF9EA1AD);

    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // City blocks on a slightly rotated grid.
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-.12);
    canvas.translate(-size.width / 2, -size.height / 2);
    const cell = 64.0;
    for (var x = -cell * 3; x < size.width + cell * 3; x += cell) {
      for (var y = -cell * 3; y < size.height + cell * 3; y += cell) {
        final r = RRect.fromRectAndRadius(Rect.fromLTWH(x + 5, y + 5, cell - 10, cell - 10), const Radius.circular(6));
        canvas.drawRRect(r, Paint()..color = block);
      }
    }
    canvas.restore();

    // Parks.
    final parkPaint = Paint()..color = park;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * .62, size.height * .52, size.width * .3, size.height * .14),
            const Radius.circular(18)),
        parkPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * .02, size.height * .10, size.width * .26, size.height * .14), parkPaint);

    // River.
    final river = Path()
      ..moveTo(-20, size.height * .78)
      ..cubicTo(size.width * .3, size.height * .66, size.width * .55, size.height * .9, size.width + 20, size.height * .70);
    canvas.drawPath(
        river,
        Paint()
          ..color = water
          ..style = PaintingStyle.stroke
          ..strokeWidth = 34
          ..strokeCap = StrokeCap.round);

    // Major roads.
    final roadPaint = Paint()
      ..color = major
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, size.height * .32), Offset(size.width, size.height * .12), roadPaint);
    canvas.drawLine(Offset(size.width * .42, 0), Offset(size.width * .56, size.height), roadPaint);
    canvas.drawPath(
        Path()
          ..moveTo(0, size.height * .58)
          ..quadraticBezierTo(size.width * .5, size.height * .5, size.width, size.height * .6),
        roadPaint..color = road);

    _label(canvas, 'KING FAHD RD', Offset(size.width * .47, size.height * .62), text, -1.42);
    _label(canvas, 'AL OLAYA', Offset(size.width * .14, size.height * .27), text, -.2);
    _label(canvas, 'Wadi Hanifa', Offset(size.width * .6, size.height * .78), text, 0, italic: true);
    _label(canvas, 'Salam Park', Offset(size.width * .7, size.height * .58), text, 0);

    // Route.
    final route = Path()..moveTo(p(_route.first).dx, p(_route.first).dy);
    for (var i = 1; i < _route.length; i++) {
      final a = p(_route[i - 1]), b = p(_route[i]);
      final mid = Offset.lerp(a, b, .5)!;
      route.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
      if (i == _route.length - 1) route.lineTo(b.dx, b.dy);
    }
    final metric = route.computeMetrics().first;
    final travelled = metric.length * progress.value.clamp(0.0, 1.0);

    canvas.drawPath(
        route,
        Paint()
          ..color = primary.withValues(alpha: .18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round);

    // Remaining route: dashed.
    final dash = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var d = travelled; d < metric.length; d += 16) {
      canvas.drawPath(metric.extractPath(d, math.min(d + 8, metric.length)), dash);
    }
    // Travelled route: solid gradient.
    canvas.drawPath(
        metric.extractPath(0, travelled),
        Paint()
          ..shader = ui.Gradient.linear(p(_route.first), p(_route.last), [secondary, primary])
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round);

    // Origin.
    final origin = p(_route.first);
    canvas.drawCircle(origin, 13, Paint()..color = dark ? const Color(0xFF2B2F3A) : Colors.white);
    canvas.drawCircle(origin, 7, Paint()..color = dark ? Colors.white : const Color(0xFF16171D));

    // Destination with pulse.
    final dest = p(_route.last);
    for (final phase in [0.0, .5]) {
      final t = (pulse.value + phase) % 1;
      canvas.drawCircle(dest, 12 + 30 * t, Paint()..color = primary.withValues(alpha: .35 * (1 - t)));
    }
    _pin(canvas, dest);

    // Courier.
    final tan = metric.getTangentForOffset(math.max(.1, travelled))!;
    final pos = tan.position;
    canvas.drawCircle(pos.translate(0, 4), 22,
        Paint()
          ..color = Colors.black.withValues(alpha: .25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(pos, 22, Paint()..color = Colors.white);
    canvas.drawCircle(pos, 17, Paint()..color = primary);
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    // Material icon points north; rotate to the route's bearing.
    canvas.rotate(-tan.angle + math.pi / 2);
    _icon(canvas, Icons.navigation_rounded, 20, Colors.white);
    canvas.restore();

    // Floating label.
    final tp = TextPainter(
      text: TextSpan(
          text: label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos.translate(0, -42), width: tp.width + 22, height: 28), const Radius.circular(14));
    canvas.drawRRect(box, Paint()..color = dark ? const Color(0xFF2B2F3A) : const Color(0xFF16171D));
    tp.paint(canvas, box.center - Offset(tp.width / 2, tp.height / 2));
  }

  void _pin(Canvas canvas, Offset at) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    final pin = Path()
      ..moveTo(0, 0)
      ..cubicTo(-6, -10, -16, -18, -16, -30)
      ..arcToPoint(const Offset(16, -30), radius: const Radius.circular(16))
      ..cubicTo(16, -18, 6, -10, 0, 0)
      ..close();
    canvas.drawShadow(pin, Colors.black, 4, false);
    canvas.drawPath(pin, Paint()..color = primary);
    canvas.drawCircle(const Offset(0, -30), 7, Paint()..color = Colors.white);
    canvas.restore();
  }

  void _icon(Canvas canvas, IconData icon, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, fontSize: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  }

  void _label(Canvas canvas, String s, Offset at, Color color, double angle, {bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(
              color: color,
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(angle);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.primary != primary || old.secondary != secondary || old.dark != dark || old.label != label;
}
