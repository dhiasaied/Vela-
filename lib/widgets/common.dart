import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/theme_controller.dart';
import 'package_box.dart';

/// Rounded white/dark card used everywhere.
class VelaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const VelaCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class CourierAvatar extends StatelessWidget {
  final Courier courier;
  final double radius;
  const CourierAvatar(this.courier, {super.key, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: courier.avatarColor,
      child: Text(courier.initials,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: radius * .7)),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final ShipmentStatus status;
  final bool filled;
  const StatusBadge(this.status, {super.key, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final delivered = status == ShipmentStatus.delivered;
    final color = delivered ? const Color(0xFF10B981) : context.cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? (context.isDark ? Colors.white : const Color(0xFF16171D)) : color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(status.icon, size: 13, color: filled ? (context.isDark ? Colors.black : Colors.white) : color),
        const SizedBox(width: 4),
        Text(status.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: filled ? (context.isDark ? Colors.black : Colors.white) : color)),
      ]),
    );
  }
}

/// Horizontal progress stepper with animated fill (Order → Delivered).
class ProgressStepper extends StatelessWidget {
  final int step; // 0..4
  final bool showLabel;
  const ProgressStepper({super.key, required this.step, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final p = context.cs.primary;
    const steps = 5;
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: step / (steps - 1)),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => SizedBox(
          height: showLabel ? 44 : 20,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(height: 4, decoration: BoxDecoration(color: context.line, borderRadius: BorderRadius.circular(4))),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: (w - 16) * t,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [p, context.cs.secondary]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            for (var i = 0; i < steps; i++)
              Positioned(
                left: 8 + (w - 16) * i / (steps - 1) - 9,
                top: 1,
                child: _Dot(active: t * (steps - 1) >= i - .01, current: i == step),
              ),
            if (showLabel)
              Positioned(
                left: (8 + (w - 16) * t - 40).clamp(0, w - 80),
                top: 24,
                child: SizedBox(
                  width: 80,
                  child: Text(ShipmentStatus.values[step].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: p)),
                ),
              ),
          ]),
        ),
      );
    });
  }
}

class _Dot extends StatelessWidget {
  final bool active, current;
  const _Dot({required this.active, required this.current});

  @override
  Widget build(BuildContext context) {
    final p = context.cs.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? p : context.card,
        border: Border.all(color: active ? p : context.line, width: 3),
        boxShadow: current ? [BoxShadow(color: p.withValues(alpha: .45), blurRadius: 10)] : null,
      ),
      child: active ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
    );
  }
}

/// List card for a shipment, used on Home and Shipments tabs.
class ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTap;
  const ShipmentCard({super.key, required this.shipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    return VelaCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Hero(tag: 'box-${s.id}', child: PackageBox(size: 54, tint: s.boxTint)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 3),
              Text('#${s.id}', style: TextStyle(color: context.muted, fontSize: 12, letterSpacing: .4)),
            ]),
          ),
          StatusBadge(s.status),
        ]),
        const SizedBox(height: 14),
        ProgressStepper(step: s.status.step, showLabel: false),
        const SizedBox(height: 10),
        Row(children: [
          _Place(label: 'From', value: s.fromShort),
          Icon(Icons.arrow_forward_rounded, size: 16, color: context.muted),
          const SizedBox(width: 12),
          _Place(label: 'To', value: s.toShort),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('ETA', style: TextStyle(fontSize: 11, color: context.muted)),
            Text(s.eta, style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
        ]),
      ]),
    );
  }
}

class _Place extends StatelessWidget {
  final String label, value;
  const _Place({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: context.muted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      );
}

/// Slide + fade entrance for list items, staggered by [index].
class StaggeredIn extends StatelessWidget {
  final int index;
  final Widget child;
  const StaggeredIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 30 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color, iconColor;
  final double size;
  const CircleIconButton(
      {super.key, required this.icon, required this.onTap, this.color, this.iconColor, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? context.card,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(dimension: size, child: Icon(icon, size: size * .45, color: iconColor)),
      ),
    );
  }
}
