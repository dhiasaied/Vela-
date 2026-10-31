import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/color_picker_sheet.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final store = StoreScope.of(context);
    final cs = context.cs;
    final delivered = store.shipments.where((s) => s.status == ShipmentStatus.delivered).length;

    void soon(String what) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text('$what opened')));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          VelaCard(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [cs.primary, cs.secondary])),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: context.card,
                  child: Text('D', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: cs.primary)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Dhia Eddine Saied', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  Text('Gold member', style: TextStyle(color: context.muted)),
                ]),
              ),
              CircleIconButton(icon: Icons.edit_rounded, color: context.line, onTap: () => soon('Edit profile')),
            ]),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _Metric('${store.shipments.length}', 'Shipments'),
            _Metric('$delivered', 'Delivered'),
            _Metric('${store.shipments.where((s) => s.favorite).length}', 'Saved'),
          ]),
          const SizedBox(height: 24),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          VelaCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Accent colour', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showColorPicker(context),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Customize'),
                ),
              ]),
              const SizedBox(height: 4),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accentPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final p = accentPresets[i];
                    final sel = p.primary == t.primary;
                    return GestureDetector(
                      onTap: () => t.applyPreset(p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [p.primary, p.secondary]),
                          border: Border.all(color: sel ? context.cs.onSurface : Colors.transparent, width: 3),
                        ),
                        child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              Divider(color: context.line, height: 28),
              Row(children: [
                Icon(Icons.dark_mode_rounded, color: cs.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700))),
                Switch(value: t.isDark, onChanged: t.toggleDark),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          VelaCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(children: [
              for (final e in const [
                (Icons.location_on_rounded, 'Saved addresses'),
                (Icons.credit_card_rounded, 'Payment methods'),
                (Icons.notifications_active_rounded, 'Notification settings'),
                (Icons.help_rounded, 'Help center'),
              ])
                ListTile(
                  leading: Icon(e.$1, color: cs.primary),
                  title: Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.muted),
                  onTap: () => soon(e.$2),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: VelaCard(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: context.cs.primary)),
              Text(label, style: TextStyle(color: context.muted, fontSize: 12)),
            ]),
          ),
        ),
      );
}
