import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/common.dart';
import 'tracking_screen.dart';

class NotificationsScreen extends StatelessWidget {
  /// True when pushed as its own route (shows a back button).
  final bool standalone;
  const NotificationsScreen({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final items = store.notifications;
    final body = SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(children: [
            if (standalone) ...[
              CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 12),
            ],
            Text('Inbox', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            TextButton(
                onPressed: store.unread == 0 ? null : store.markAllRead, child: const Text('Mark all read')),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = items[i];
              return StaggeredIn(
                index: i,
                child: VelaCard(
                  onTap: () {
                    store.markRead(n);
                    final match = RegExp(r'[A-Z]\d{8}').firstMatch(n.body);
                    final s = match == null ? null : store.find(match.group(0)!);
                    if (s != null) openTracking(context, s);
                  },
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: context.cs.primary.withValues(alpha: n.read ? .06 : .15), shape: BoxShape.circle),
                      child: Icon(n.icon, color: context.cs.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(
                              child: Text(n.title,
                                  style: TextStyle(fontWeight: n.read ? FontWeight.w600 : FontWeight.w800))),
                          Text(n.time, style: TextStyle(color: context.muted, fontSize: 12)),
                        ]),
                        const SizedBox(height: 3),
                        Text(n.body, style: TextStyle(color: context.muted, fontSize: 13)),
                      ]),
                    ),
                    AnimatedOpacity(
                      opacity: n.read ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8, top: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: context.cs.primary, shape: BoxShape.circle),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
    return standalone ? Scaffold(body: body) : body;
  }
}
