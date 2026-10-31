import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Opens the interactive colour selector as a modal bottom sheet.
Future<void> showColorPicker(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ColorPickerSheet(),
    );

class ColorPickerSheet extends StatefulWidget {
  const ColorPickerSheet({super.key});

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late double _hue, _sat, _light;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final hsl = HSLColor.fromColor(ThemeScope.of(context).primary);
    _hue = hsl.hue;
    _sat = hsl.saturation;
    _light = hsl.lightness;
  }

  void _pushCustom(ThemeController t) =>
      t.setColors(HSLColor.fromAHSL(1, _hue, _sat, _light).toColor());

  @override
  Widget build(BuildContext context) {
    final t = ThemeScope.of(context);
    final hues = [for (var h = 0; h <= 360; h += 30) HSLColor.fromAHSL(1, h.toDouble(), _sat, _light).toColor()];

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 44, height: 5, decoration: BoxDecoration(color: context.line, borderRadius: BorderRadius.circular(9))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Text('Theme studio', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Icon(Icons.dark_mode_rounded, color: context.muted, size: 20),
            Switch(value: t.isDark, onChanged: t.toggleDark),
          ]),
          const SizedBox(height: 8),
          _PreviewCard(primary: t.primary, secondary: t.secondary),
          const SizedBox(height: 20),
          Text('Presets', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in accentPresets)
                _Swatch(
                  preset: p,
                  selected: p.primary == t.primary,
                  onTap: () {
                    t.applyPreset(p);
                    final hsl = HSLColor.fromColor(p.primary);
                    setState(() {
                      _hue = hsl.hue;
                      _sat = hsl.saturation;
                      _light = hsl.lightness;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Custom colour', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _GradientSlider(
            label: 'Hue',
            value: _hue / 360,
            colors: hues,
            onChanged: (v) => setState(() {
              _hue = v * 360;
              _pushCustom(t);
            }),
          ),
          _GradientSlider(
            label: 'Saturation',
            value: _sat,
            colors: [
              HSLColor.fromAHSL(1, _hue, 0, _light).toColor(),
              HSLColor.fromAHSL(1, _hue, 1, _light).toColor(),
            ],
            onChanged: (v) => setState(() {
              _sat = v;
              _pushCustom(t);
            }),
          ),
          _GradientSlider(
            label: 'Brightness',
            value: (_light - .2) / .55,
            colors: [
              HSLColor.fromAHSL(1, _hue, _sat, .2).toColor(),
              HSLColor.fromAHSL(1, _hue, _sat, .75).toColor(),
            ],
            onChanged: (v) => setState(() {
              _light = .2 + v * .55;
              _pushCustom(t);
            }),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color primary, secondary;
  const _PreviewCard({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(colors: [primary, secondary]),
        boxShadow: [BoxShadow(color: primary.withValues(alpha: .35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(children: [
        const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.local_shipping_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live preview', style: TextStyle(color: Colors.white70, fontSize: 12)),
              SizedBox(height: 2),
              Text('Arriving in 8 min',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Text('Track', style: TextStyle(color: primary, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _Swatch extends StatelessWidget {
  final AccentPreset preset;
  final bool selected;
  final VoidCallback onTap;
  const _Swatch({required this.preset, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? preset.primary : Colors.transparent, width: 2.5),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [preset.primary, preset.secondary]),
            ),
            child: AnimatedScale(
              scale: selected ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(preset.name, style: TextStyle(fontSize: 11, color: context.muted)),
      ]),
    );
  }
}

/// A slider whose track is a colour gradient.
class _GradientSlider extends StatelessWidget {
  final String label;
  final double value;
  final List<Color> colors;
  final ValueChanged<double> onChanged;
  const _GradientSlider({required this.label, required this.value, required this.colors, required this.onChanged});

  Color _sample(double t) {
    final pos = t * (colors.length - 1);
    final i = pos.floor().clamp(0, colors.length - 2);
    return Color.lerp(colors[i], colors[i + 1], pos - i)!;
  }

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.muted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          void update(Offset local) => onChanged((local.dx / c.maxWidth).clamp(0.0, 1.0));
          return GestureDetector(
            onTapDown: (d) => update(d.localPosition),
            onHorizontalDragUpdate: (d) => update(d.localPosition),
            child: SizedBox(
              height: 28,
              child: Stack(clipBehavior: Clip.none, alignment: Alignment.centerLeft, children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(colors: colors),
                  ),
                ),
                Positioned(
                  left: v * c.maxWidth - 14,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _sample(v),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}
