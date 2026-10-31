import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme/theme_controller.dart';
import '../widgets/common.dart';

class ChatScreen extends StatefulWidget {
  final Shipment shipment;
  const ChatScreen({super.key, required this.shipment});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  static const _quick = ['Where are you?', 'Please leave it at the door', 'Thank you!'];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(AppStore store, String text) {
    if (text.trim().isEmpty) return;
    store.send(widget.shipment, text.trim());
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final messages = store.chatFor(widget.shipment);
    final c = widget.shipment.courier;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Row(children: [
          CourierAvatar(c, radius: 18),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text('Online · ${widget.shipment.id}', style: TextStyle(fontSize: 12, color: context.cs.primary)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) => StaggeredIn(index: 0, child: _Bubble(messages[i])),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _quick.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ActionChip(
              label: Text(_quick[i]),
              backgroundColor: context.card,
              side: BorderSide(color: context.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => _send(store, _quick[i]),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(color: context.card, borderRadius: BorderRadius.circular(26)),
                  child: TextField(
                    controller: _input,
                    onSubmitted: (v) => _send(store, v),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Message your courier'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleIconButton(
                icon: Icons.send_rounded,
                size: 50,
                color: context.cs.primary,
                iconColor: Colors.white,
                onTap: () => _send(store, _input.text),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage m;
  const _Bubble(this.m);

  @override
  Widget build(BuildContext context) {
    final p = context.cs.primary;
    final t = TimeOfDay.fromDateTime(m.time).format(context);
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          gradient: m.mine ? LinearGradient(colors: [p, context.cs.secondary]) : null,
          color: m.mine ? null : context.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(m.mine ? 20 : 4),
            bottomRight: Radius.circular(m.mine ? 4 : 20),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(m.text, style: TextStyle(color: m.mine ? Colors.white : null)),
          const SizedBox(height: 2),
          Text(t, style: TextStyle(fontSize: 10, color: m.mine ? Colors.white70 : context.muted)),
        ]),
      ),
    );
  }
}
