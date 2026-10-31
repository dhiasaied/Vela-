import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/common.dart';
import '../widgets/package_box.dart';
import 'notifications_screen.dart';
import 'tracking_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSeeAll;
  final VoidCallback onSend;
  const HomeScreen({super.key, required this.onSeeAll, required this.onSend});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _filters = ['All', 'Active', 'Pending', 'Delivered'];
  int _filter = 0;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Shipment s) => switch (_filter) {
        1 => s.status == ShipmentStatus.inTransit || s.status == ShipmentStatus.outForDelivery,
        2 => s.status == ShipmentStatus.pending || s.status == ShipmentStatus.packed,
        3 => s.status == ShipmentStatus.delivered,
        _ => true,
      };

  void _track(AppStore store) {
    final s = store.find(_search.text);
    FocusScope.of(context).unfocus();
    if (s != null) {
      openTracking(context, s);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(_search.text.isEmpty ? 'Enter a tracking number, e.g. M87952264' : 'No parcel found for "${_search.text}"'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final cs = context.cs;
    final live = store.shipments.firstWhere((s) => s.status == ShipmentStatus.outForDelivery,
        orElse: () => store.shipments.first);
    final list = store.shipments.where(_matches).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverList.list(children: [
              Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primary.withValues(alpha: .15),
                  child: Text('D', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good afternoon,', style: TextStyle(color: context.muted, fontSize: 13)),
                    const Text('Dhia 👋', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ]),
                ),
                CircleIconButton(icon: Icons.palette_rounded, iconColor: cs.primary, onTap: () => showColorPicker(context)),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: store.unread > 0,
                  label: Text('${store.unread}'),
                  backgroundColor: cs.primary,
                  child: CircleIconButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const NotificationsScreen(standalone: true))),
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              Text('My Shipping', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 14),
              _SearchBar(controller: _search, onSubmit: () => _track(store)),
              const SizedBox(height: 20),
              _LiveCard(shipment: live),
              const SizedBox(height: 20),
              _QuickActions(onSend: widget.onSend, onScan: () {
                _search.text = live.id;
                _track(store);
              }),
              const SizedBox(height: 24),
              Row(children: [
                Text('Recent shipments', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(onPressed: widget.onSeeAll, child: const Text('See all')),
              ]),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final sel = i == _filter;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? (context.isDark ? Colors.white : const Color(0xFF16171D)) : context.card,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(_filters[i],
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: sel ? (context.isDark ? Colors.black : Colors.white) : context.muted)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: list.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: Text('Nothing here yet', style: TextStyle(color: context.muted))),
                    ),
                  )
                : SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => StaggeredIn(
                      key: ValueKey('${list[i].id}-$_filter'),
                      index: i,
                      child: ShipmentCard(shipment: list[i], onTap: () => openTracking(context, list[i])),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _SearchBar({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 16, right: 6),
      decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Icon(Icons.search_rounded, color: context.muted),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter tracking number',
              hintStyle: TextStyle(color: context.muted),
            ),
          ),
        ),
        CircleIconButton(
          icon: Icons.arrow_forward_rounded,
          size: 44,
          color: context.cs.primary,
          iconColor: Colors.white,
          onTap: onSubmit,
        ),
      ]),
    );
  }
}

/// Gradient hero card highlighting the parcel currently out for delivery.
class _LiveCard extends StatelessWidget {
  final Shipment shipment;
  const _LiveCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return GestureDetector(
      onTap: () => openTracking(context, shipment),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cs.primary, cs.secondary]),
          boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: .35), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            right: -6,
            top: -8,
            child: PackageBox(size: 96, tint: shipment.boxTint),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                _LiveDot(),
                SizedBox(width: 6),
                Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ]),
            ),
            const SizedBox(height: 14),
            Text('#${shipment.id}', style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: .5)),
            const SizedBox(height: 2),
            Text('Arriving in ${shipment.eta}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            const SizedBox(height: 16),
            Row(children: [
              CourierAvatar(shipment.courier, radius: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${shipment.courier.name} is on the way',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text('Track', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: .3, end: 1.0).animate(_c),
        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
      );
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onSend, onScan;
  const _QuickActions({required this.onSend, required this.onScan});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, VoidCallback onTap) => Expanded(
          child: VelaCard(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: context.cs.primary.withValues(alpha: .12), shape: BoxShape.circle),
                child: Icon(icon, color: context.cs.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ]),
          ),
        );
    return Row(children: [
      item(Icons.qr_code_scanner_rounded, 'Scan', onScan),
      const SizedBox(width: 10),
      item(Icons.send_rounded, 'Send', onSend),
      const SizedBox(width: 10),
      item(Icons.calculate_rounded, 'Rates', () => _showRates(context)),
      const SizedBox(width: 10),
      item(Icons.palette_rounded, 'Theme', () => showColorPicker(context)),
    ]);
  }

  void _showRates(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Delivery rates', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final r in const [
            ('Standard', '3–5 days', 'from \$6.90'),
            ('Express', '1–2 days', 'from \$14.50'),
            ('Same day', 'Within 6 h', 'from \$24.00'),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.local_shipping_outlined, color: context.cs.primary),
              title: Text(r.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(r.$2),
              trailing: Text(r.$3, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }
}
