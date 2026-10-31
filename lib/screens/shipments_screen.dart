import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/common.dart';
import 'tracking_screen.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final all = store.shipments;
    final tabs = <(String, List<Shipment>)>[
      ('Ongoing', all.where((s) => s.status != ShipmentStatus.delivered).toList()),
      ('Delivered', all.where((s) => s.status == ShipmentStatus.delivered).toList()),
      ('Saved', all.where((s) => s.favorite).toList()),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Shipments', style: Theme.of(context).textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              _Stat(label: 'Total', value: '${all.length}', icon: Icons.inventory_2_rounded),
              const SizedBox(width: 10),
              _Stat(label: 'Active', value: '${tabs[0].$2.length}', icon: Icons.local_shipping_rounded),
              const SizedBox(width: 10),
              _Stat(label: 'Spent', value: '\$${all.fold<double>(0, (a, s) => a + s.price).round()}', icon: Icons.payments_rounded),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(20)),
            child: TabBar(
              dividerHeight: 0,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: context.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              indicator: BoxDecoration(color: context.cs.primary, borderRadius: BorderRadius.circular(16)),
              tabs: [for (final t in tabs) Tab(height: 40, text: '${t.$1} (${t.$2.length})')],
            ),
          ),
          Expanded(
            child: TabBarView(children: [
              for (final t in tabs)
                t.$2.isEmpty
                    ? Center(child: Text('No shipments', style: TextStyle(color: context.muted)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        itemCount: t.$2.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final s = t.$2[i];
                          return StaggeredIn(
                            index: i,
                            child: Dismissible(
                              key: ValueKey('${t.$1}-${s.id}'),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) async {
                                store.toggleFavorite(s);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(s.favorite ? 'Saved ${s.id}' : 'Removed ${s.id} from saved'),
                                ));
                                return false;
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                decoration: BoxDecoration(
                                    color: context.cs.primary.withValues(alpha: .15),
                                    borderRadius: BorderRadius.circular(24)),
                                child: Icon(s.favorite ? Icons.bookmark_remove_rounded : Icons.bookmark_add_rounded,
                                    color: context.cs.primary),
                              ),
                              child: ShipmentCard(shipment: s, onTap: () => openTracking(context, s)),
                            ),
                          );
                        },
                      ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
        child: VelaCard(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: context.cs.primary, size: 20),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label, style: TextStyle(color: context.muted, fontSize: 12)),
          ]),
        ),
      );
}
