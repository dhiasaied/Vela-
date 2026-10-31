import 'package:flutter/material.dart';

/// Isometric cardboard box illustration, painted so it needs no image assets.
class PackageBox extends StatelessWidget {
  final double size;
  final Color tint;
  const PackageBox({super.key, this.size = 64, this.tint = const Color(0xFFD9A066)});

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _BoxPainter(tint)));
}

class _BoxPainter extends CustomPainter {
  final Color tint;
  _BoxPainter(this.tint);

  Color _shade(double amount) {
    final hsl = HSLColor.fromColor(tint);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final top = Offset(w * .5, h * .12);
    final left = Offset(w * .08, h * .33);
    final right = Offset(w * .92, h * .33);
    final center = Offset(w * .5, h * .54);
    final bl = Offset(w * .08, h * .72);
    final br = Offset(w * .92, h * .72);
    final bottom = Offset(w * .5, h * .94);

    // Soft ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * .5, h * .95), width: w * .9, height: h * .1),
      Paint()
        ..color = Colors.black.withValues(alpha: .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    Path poly(List<Offset> pts) => Path()..addPolygon(pts, true);
    canvas.drawPath(poly([top, right, center, left]), Paint()..color = _shade(.12));
    canvas.drawPath(poly([left, center, bottom, bl]), Paint()..color = _shade(-.02));
    canvas.drawPath(poly([center, right, br, bottom]), Paint()..color = _shade(-.12));

    // Tape across the lid and down the front.
    final tape = Paint()..color = _shade(.28).withValues(alpha: .9);
    final t1 = Offset.lerp(top, left, .5)!, t2 = Offset.lerp(right, center, .5)!;
    final d = Offset(w * .05, -h * .028);
    canvas.drawPath(poly([t1 - d, t1 + d, t2 + d, t2 - d]), tape);
    final f1 = Offset.lerp(center, right, .5)!;
    final f2 = Offset.lerp(bottom, br, .5)!;
    final dx = Offset(w * .045, -h * .02);
    canvas.drawPath(poly([f1 - dx, f1 + dx, f2 + dx, f2 - dx]), Paint()..color = _shade(.1).withValues(alpha: .7));

    // Shipping label on the left face.
    final l1 = Offset.lerp(left, center, .2)!.translate(0, h * .1);
    final label = poly([
      l1,
      l1 + Offset(w * .22, h * .09),
      l1 + Offset(w * .22, h * .2),
      l1 + Offset(0, h * .11),
    ]);
    canvas.drawPath(label, Paint()..color = Colors.white.withValues(alpha: .92));
    final stripe = Paint()
      ..color = Colors.black26
      ..strokeWidth = w * .012;
    for (var i = 0; i < 3; i++) {
      final a = l1 + Offset(w * .03, h * (.045 + i * .035));
      canvas.drawLine(a, a + Offset(w * .15, h * .06), stripe);
    }

    // Edge highlights.
    final edge = Paint()
      ..color = Colors.white.withValues(alpha: .25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(left, center, edge);
    canvas.drawLine(center, right, edge);
    canvas.drawLine(center, bottom, edge);
  }

  @override
  bool shouldRepaint(_BoxPainter old) => old.tint != tint;
}
