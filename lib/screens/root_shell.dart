import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme/theme_controller.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'send_screen.dart';
import 'shipments_screen.dart';

/// Bottom-navigation shell with a floating, animated nav bar.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.inventory_2_rounded, 'Shipments'),
    (Icons.add_rounded, 'Send'),
    (Icons.notifications_rounded, 'Inbox'),
    (Icons.person_rounded, 'Profile'),
  ];

  void goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSeeAll: () => goTo(1), onSend: () => goTo(2)),
      const ShipmentsScreen(),
      SendScreen(onCreated: () => goTo(1)),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: SlideTransition(position: Tween(begin: const Offset(0, .03), end: Offset.zero).animate(a), child: child),
        ),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: _NavBar(index: _index, items: _items, onTap: goTo),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final List<(IconData, String)> items;
  final ValueChanged<int> onTap;
  const _NavBar({required this.index, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final unread = StoreScope.of(context).unread;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF1F2029) : const Color(0xFF16171D),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var i = 0; i < items.length; i++)
              if (i == 2)
                GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                      boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: .5), blurRadius: 16)],
                    ),
                    child: AnimatedRotation(
                      turns: index == 2 ? .125 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                )
              else
                _NavItem(
                  icon: items[i].$1,
                  label: items[i].$2,
                  selected: index == i,
                  badge: i == 3 ? unread : 0,
                  onTap: () => onTap(i),
                ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.cs.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 58,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Badge(
            isLabelVisible: badge > 0,
            label: Text('$badge'),
            backgroundColor: p,
            child: AnimatedScale(
              scale: selected ? 1.15 : 1,
              duration: const Duration(milliseconds: 250),
              child: Icon(icon, color: selected ? p : Colors.white54, size: 24),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: selected ? 18 : 0,
            height: 4,
            decoration: BoxDecoration(color: p, borderRadius: BorderRadius.circular(4)),
          ),
        ]),
      ),
    );
  }
}
