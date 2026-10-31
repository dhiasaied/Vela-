import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/common.dart';
import '../widgets/package_box.dart';
import 'tracking_screen.dart';

class SendScreen extends StatefulWidget {
  final VoidCallback onCreated;
  const SendScreen({super.key, required this.onCreated});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _form = GlobalKey<FormState>();
  final _item = TextEditingController();
  final _from = TextEditingController(text: 'Al Olaya, Riyadh');
  final _to = TextEditingController();
  final _receiver = TextEditingController();

  static const _sizes = [('S', 'Envelope', .5, 0.0), ('M', 'Small box', 2.0, 6.0), ('L', 'Medium box', 5.0, 12.0), ('XL', 'Large box', 12.0, 22.0)];
  static const _speeds = [('Standard', '3–5 days', 6.9), ('Express', '1–2 days', 14.5), ('Same day', 'Within 6 h', 24.0)];
  int _size = 1, _speed = 1;
  bool _insured = false;

  double get _price => _speeds[_speed].$3 + _sizes[_size].$4 + (_insured ? 3.5 : 0);

  @override
  void dispose() {
    for (final c in [_item, _from, _to, _receiver]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final store = StoreScope.of(context);
    final s = Shipment(
      id: AppStore.newTrackingId(),
      title: _item.text.trim(),
      from: _from.text.trim(),
      to: _to.text.trim(),
      fromShort: _from.text.split(',').first.trim(),
      toShort: _to.text.split(',').first.trim(),
      price: _price,
      weightKg: _sizes[_size].$3,
      customer: _receiver.text.trim(),
      status: ShipmentStatus.pending,
      eta: _speeds[_speed].$2,
      courier: AppStore.defaultCourier,
      events: AppStore.freshEvents(),
      boxTint: HSLColor.fromColor(context.cs.primary).withSaturation(.45).withLightness(.62).toColor(),
    );
    store.addShipment(s);
    showDialog(
      context: context,
      builder: (dCtx) => _SuccessDialog(
        shipment: s,
        onTrack: () {
          Navigator.pop(dCtx);
          openTracking(context, s);
        },
        onDone: () {
          Navigator.pop(dCtx);
          widget.onCreated();
        },
      ),
    );
    _form.currentState!.reset();
    _item.clear();
    _to.clear();
    _receiver.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SafeArea(
      bottom: false,
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
          children: [
            Text('Send a parcel', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Door-to-door delivery with live tracking', style: TextStyle(color: context.muted)),
            const SizedBox(height: 20),
            VelaCard(
              child: Column(children: [
                _Field(controller: _from, icon: Icons.trip_origin_rounded, label: 'Pickup address'),
                Divider(color: context.line, height: 20),
                _Field(controller: _to, icon: Icons.location_on_rounded, label: 'Delivery address'),
                Divider(color: context.line, height: 20),
                _Field(controller: _receiver, icon: Icons.person_rounded, label: 'Receiver name'),
                Divider(color: context.line, height: 20),
                _Field(controller: _item, icon: Icons.inventory_2_rounded, label: 'What are you sending?'),
              ]),
            ),
            const SizedBox(height: 22),
            Text('Package size', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              for (var i = 0; i < _sizes.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _size = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _size == i ? cs.primary.withValues(alpha: .12) : context.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _size == i ? cs.primary : Colors.transparent, width: 2),
                      ),
                      child: Column(children: [
                        AnimatedScale(
                          scale: _size == i ? 1.1 : .85,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          child: PackageBox(size: 26.0 + i * 6),
                        ),
                        const SizedBox(height: 6),
                        Text(_sizes[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text('≤ ${_sizes[i].$3} kg', style: TextStyle(fontSize: 11, color: context.muted)),
                      ]),
                    ),
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 22),
            Text('Delivery speed', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (var i = 0; i < _speeds.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: VelaCard(
                  onTap: () => setState(() => _speed = i),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Icon([Icons.local_shipping_outlined, Icons.bolt_rounded, Icons.rocket_launch_rounded][i],
                        color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_speeds[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(_speeds[i].$2, style: TextStyle(color: context.muted, fontSize: 12)),
                      ]),
                    ),
                    Text('\$${_speeds[i].$3.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Radio<int>(value: i, groupValue: _speed, onChanged: (v) => setState(() => _speed = v!)),
                  ]),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _insured,
              onChanged: (v) => setState(() => _insured = v),
              title: const Text('Parcel insurance', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Covers up to \$500 for \$3.50'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: context.isDark ? Colors.white : const Color(0xFF16171D),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Total', style: TextStyle(color: context.isDark ? Colors.black54 : Colors.white60)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _price),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Text('\$${v.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: context.isDark ? Colors.black : Colors.white)),
                  ),
                ]),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Create', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  const _Field({required this.controller, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: context.cs.primary),
          labelText: label,
          labelStyle: TextStyle(color: context.muted),
        ),
      );
}

class _SuccessDialog extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onTrack, onDone;
  const _SuccessDialog({required this.shipment, required this.onTrack, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Dialog(
      backgroundColor: context.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, v, __) => Transform.scale(
              scale: v,
              child: CircleAvatar(
                radius: 38,
                backgroundColor: cs.primary,
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 42),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Shipment created!', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Tracking ID', style: TextStyle(color: context.muted)),
          Text(shipment.id, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: .5)),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: onDone, child: const Text('Done'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: onTrack, child: const Text('Track'))),
          ]),
        ]),
      ),
    );
  }
}
