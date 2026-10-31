import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/common.dart';
import '../widgets/live_map.dart';
import '../widgets/package_box.dart';
import 'chat_screen.dart';

void openTracking(BuildContext context, Shipment s) {
  Navigator.of(context).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 550),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => TrackingScreen(shipment: s),
    transitionsBuilder: (_, a, __, child) {
      final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: c,
        child: SlideTransition(position: Tween(begin: const Offset(0, .08), end: Offset.zero).animate(c), child: child),
      );
    },
  ));
}

class TrackingScreen extends StatefulWidget {
  final Shipment shipment;
  const TrackingScreen({super.key, required this.shipment});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _mapKey = GlobalKey<LiveMapState>();
  late final ValueNotifier<double> _progress = ValueNotifier(_startProgress);

  double get _startProgress => switch (widget.shipment.status) {
        ShipmentStatus.pending => 0,
        ShipmentStatus.packed => .05,
        ShipmentStatus.inTransit => .3,
        ShipmentStatus.outForDelivery => .55,
        ShipmentStatus.delivered => 1,
      };

  bool get _moving =>
      widget.shipment.status == ShipmentStatus.inTransit || widget.shipment.status == ShipmentStatus.outForDelivery;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.shipment;
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: LiveMap(
            key: _mapKey,
            progress: _progress,
            running: _moving,
            courierLabel: s.courier.name.split(' ').first,
          ),
        ),
        // Top bar.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(30)),
                      child: const Text('Track Package', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: context.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  onSelected: (v) {
                    if (v == 'theme') showColorPicker(context);
                    if (v == 'copy') _copy(context);
                    if (v == 'fav') StoreScope.of(context).toggleFavorite(s);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'copy', child: Text('Copy tracking ID')),
                    PopupMenuItem(value: 'fav', child: Text(s.favorite ? 'Remove from saved' : 'Save shipment')),
                    const PopupMenuItem(value: 'theme', child: Text('Change colours')),
                  ],
                  child: const IgnorePointer(child: CircleIconButton(icon: Icons.more_horiz_rounded, onTap: _noop)),
                ),
              ]),
            ),
          ),
        ),
        // Map controls.
        Positioned(
          right: 16,
          top: MediaQuery.of(context).padding.top + 80,
          child: Column(children: [
            CircleIconButton(icon: Icons.my_location_rounded, onTap: () => _mapKey.currentState?.recenter()),
            const SizedBox(height: 10),
            CircleIconButton(
              icon: context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              onTap: () {
                final t = ThemeScope.of(context);
                t.toggleDark(!t.isDark);
              },
            ),
          ]),
        ),
        _Sheet(shipment: s, progress: _progress),
      ]),
    );
  }

  static void _noop() {}

  void _copy(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.shipment.id));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Tracking ID copied')));
  }
}

class _Sheet extends StatelessWidget {
  final Shipment shipment;
  final ValueNotifier<double> progress;
  const _Sheet({required this.shipment, required this.progress});

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    return DraggableScrollableSheet(
      initialChildSize: .5,
      minChildSize: .28,
      maxChildSize: .92,
      snap: true,
      snapSizes: const [.5],
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .15), blurRadius: 30)],
        ),
        child: ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
          children: [
            Center(
              child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: context.line, borderRadius: BorderRadius.circular(9))),
            ),
            const SizedBox(height: 14),
            _CourierCard(shipment: s, progress: progress),
            const SizedBox(height: 12),
            _TrackingCard(shipment: s),
            const SizedBox(height: 12),
            _Timeline(shipment: s),
          ],
        ),
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  final Shipment shipment;
  final ValueNotifier<double> progress;
  const _CourierCard({required this.shipment, required this.progress});

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    final cs = context.cs;
    return VelaCard(
      child: Column(children: [
        Row(children: [
          CourierAvatar(s.courier, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Courier', style: TextStyle(color: context.muted, fontSize: 12)),
              Text(s.courier.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Row(children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                Text(' ${s.courier.rating} · ${s.courier.vehicle}',
                    style: TextStyle(color: context.muted, fontSize: 12)),
              ]),
            ]),
          ),
          CircleIconButton(
            icon: Icons.call_rounded,
            color: context.isDark ? Colors.white : const Color(0xFF16171D),
            iconColor: context.isDark ? Colors.black : Colors.white,
            onTap: () => _call(context, s.courier),
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.chat_bubble_rounded,
            color: cs.primary,
            iconColor: Colors.white,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(shipment: s))),
          ),
        ]),
        const SizedBox(height: 14),
        ValueListenableBuilder<double>(
          valueListenable: progress,
          builder: (context, p, _) {
            final arrived = p >= 1;
            final minutes = ((1 - p) * 18).ceil();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Icon(arrived ? Icons.verified_rounded : Icons.delivery_dining_rounded, color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (c, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                            position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(a), child: c)),
                    child: Text(
                      key: ValueKey(arrived ? -1 : minutes),
                      arrived ? 'Delivered — enjoy your parcel!' : shipmentMovingLabel(shipment.status, minutes),
                      style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                  ),
                ),
                Text('${(p * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary)),
              ]),
            );
          },
        ),
      ]),
    );
  }

  void _call(BuildContext context, Courier c) {
    showDialog(
      context: context,
      builder: (_) => _CallDialog(courier: c),
    );
  }
}

String shipmentMovingLabel(ShipmentStatus st, int minutes) => switch (st) {
      ShipmentStatus.pending => 'Waiting for pickup',
      ShipmentStatus.packed => 'Packed — awaiting courier',
      _ => 'On the way · arriving in $minutes min',
    };

class _CallDialog extends StatefulWidget {
  final Courier courier;
  const _CallDialog({required this.courier});

  @override
  State<_CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<_CallDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Dialog(
      backgroundColor: context.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 130,
            height: 130,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Stack(alignment: Alignment.center, children: [
                for (final phase in [0.0, .33, .66])
                  Builder(builder: (_) {
                    final t = (_c.value + phase) % 1;
                    return Container(
                      width: 60 + 70 * t,
                      height: 60 + 70 * t,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: cs.primary.withValues(alpha: .3 * (1 - t))),
                    );
                  }),
                CourierAvatar(widget.courier, radius: 32),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.courier.name, style: Theme.of(context).textTheme.titleLarge),
          Text('Calling…', style: TextStyle(color: context.muted)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            CircleIconButton(icon: Icons.mic_off_rounded, color: context.line, onTap: () {}),
            CircleIconButton(
              icon: Icons.call_end_rounded,
              size: 60,
              color: const Color(0xFFEF4444),
              iconColor: Colors.white,
              onTap: () => Navigator.pop(context),
            ),
            CircleIconButton(icon: Icons.volume_up_rounded, color: context.line, onTap: () {}),
          ]),
        ]),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final Shipment shipment;
  const _TrackingCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    Widget info(String label, String value) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: context.muted, fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
          ]),
        );
    return VelaCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Tracking ID', style: TextStyle(color: context.muted, fontSize: 12)),
          const Spacer(),
          StatusBadge(s.status, filled: true),
        ]),
        const SizedBox(height: 4),
        Text(s.id, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -.5)),
        const SizedBox(height: 16),
        ProgressStepper(step: s.status.step),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(children: [
              Row(children: [info('From', s.fromShort), info('To', s.to)]),
              const SizedBox(height: 14),
              Row(children: [info('Price', '\$${s.price.toStringAsFixed(2)}'), info('Customer', s.customer)]),
              const SizedBox(height: 14),
              Row(children: [info('Weight', '${s.weightKg} kg'), info('Item', s.title)]),
            ]),
          ),
          Hero(tag: 'box-${s.id}', child: PackageBox(size: 92, tint: s.boxTint)),
        ]),
      ]),
    );
  }
}

class _Timeline extends StatelessWidget {
  final Shipment shipment;
  const _Timeline({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final events = shipment.events;
    final p = context.cs.primary;
    return VelaCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Shipment history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        for (var i = 0; i < events.length; i++)
          StaggeredIn(
            index: i,
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Column(children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: events[i].done ? p : context.line,
                    ),
                    child: Icon(events[i].done ? Icons.check_rounded : Icons.circle,
                        size: events[i].done ? 14 : 6, color: events[i].done ? Colors.white : context.muted),
                  ),
                  if (i < events.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: events[i + 1].done ? p : context.line,
                      ),
                    ),
                ]),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(events[i].title,
                          style: TextStyle(fontWeight: FontWeight.w700, color: events[i].done ? null : context.muted)),
                      Text(events[i].place, style: TextStyle(color: context.muted, fontSize: 12)),
                    ]),
                  ),
                ),
                Text(events[i].time, style: TextStyle(color: context.muted, fontSize: 12)),
              ]),
            ),
          ),
      ]),
    );
  }
}
