import 'package:flutter/material.dart';

import 'models.dart';

const _dana = Courier('Dana Reid', 'Moto · KSA 4821', 4.9, Color(0xFF6C5CE7));
const _omar = Courier('Omar Haddad', 'Van · KSA 1177', 4.8, Color(0xFF00B894));
const _lina = Courier('Lina Farouk', 'Bike · KSA 0932', 4.7, Color(0xFFE17055));

List<TrackingEvent> _events(int doneCount) {
  const all = [
    TrackingEvent('Order placed', 'Palm Springs Hub', '09:12 AM', true),
    TrackingEvent('Packed & labelled', 'Palm Springs Hub', '10:40 AM', true),
    TrackingEvent('In transit', 'Riyadh Sorting Center', '01:05 PM', true),
    TrackingEvent('Out for delivery', 'Diriyah, Riyadh', '03:22 PM', true),
    TrackingEvent('Delivered', 'Front door', '—', true),
  ];
  return [
    for (var i = 0; i < all.length; i++)
      TrackingEvent(all[i].title, all[i].place, i < doneCount ? all[i].time : 'Pending', i < doneCount),
  ];
}

/// In-memory app state: shipments, chat threads and notifications.
class AppStore extends ChangeNotifier {
  final List<Shipment> shipments = [
    Shipment(
      id: 'M87952264',
      title: 'Wireless headphones',
      from: 'Palm Springs, CA',
      to: 'Diriyah, Riyadh',
      fromShort: 'Palm Springs',
      toShort: 'Diriyah',
      price: 164.00,
      weightKg: 1.4,
      customer: 'Dhia',
      status: ShipmentStatus.outForDelivery,
      eta: '8 min',
      courier: _dana,
      events: _events(4),
      boxTint: const Color(0xFFD9A066),
      favorite: true,
    ),
    Shipment(
      id: 'V20481937',
      title: 'Ceramic vase set',
      from: 'Jeddah Port',
      to: 'Al Olaya, Riyadh',
      fromShort: 'Jeddah',
      toShort: 'Al Olaya',
      price: 89.50,
      weightKg: 3.2,
      customer: 'Noah',
      status: ShipmentStatus.inTransit,
      eta: '2 h 15 min',
      courier: _omar,
      events: _events(3),
      boxTint: const Color(0xFFC8955C),
    ),
    Shipment(
      id: 'K55310728',
      title: 'Running shoes',
      from: 'Dammam Hub',
      to: 'King Fahd Rd, Riyadh',
      fromShort: 'Dammam',
      toShort: 'King Fahd',
      price: 120.00,
      weightKg: 0.9,
      customer: 'Sara',
      status: ShipmentStatus.packed,
      eta: 'Tomorrow',
      courier: _lina,
      events: _events(2),
      boxTint: const Color(0xFFE0B07A),
    ),
    Shipment(
      id: 'P10044582',
      title: 'Mechanical keyboard',
      from: 'Dubai Mall',
      to: 'Al Malqa, Riyadh',
      fromShort: 'Dubai',
      toShort: 'Al Malqa',
      price: 210.00,
      weightKg: 1.8,
      customer: 'Dhia',
      status: ShipmentStatus.delivered,
      eta: 'Delivered',
      courier: _omar,
      events: _events(5),
      boxTint: const Color(0xFFBF8A52),
    ),
    Shipment(
      id: 'T77129003',
      title: 'Smart watch',
      from: 'Medina Center',
      to: 'Hittin, Riyadh',
      fromShort: 'Medina',
      toShort: 'Hittin',
      price: 299.00,
      weightKg: 0.4,
      customer: 'Yusuf',
      status: ShipmentStatus.pending,
      eta: 'Fri, 3 Nov',
      courier: _dana,
      events: _events(1),
      boxTint: const Color(0xFFD7A46F),
    ),
  ];

  final Map<String, List<ChatMessage>> chats = {};

  final List<AppNotification> notifications = [
    AppNotification('Courier is nearby', 'Dana Reid is 8 minutes away with M87952264.', '2m',
        Icons.delivery_dining_rounded),
    AppNotification('Package in transit', 'V20481937 left Jeddah Port.', '1h', Icons.local_shipping_rounded),
    AppNotification('Delivered', 'P10044582 was delivered to your front door.', 'Yesterday',
        Icons.verified_rounded, read: true),
    AppNotification('Promo', 'Save 20% on Express shipping this weekend.', '2d', Icons.local_offer_rounded,
        read: true),
  ];

  int get unread => notifications.where((n) => !n.read).length;

  void markAllRead() {
    for (final n in notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void markRead(AppNotification n) {
    n.read = true;
    notifyListeners();
  }

  void toggleFavorite(Shipment s) {
    s.favorite = !s.favorite;
    notifyListeners();
  }

  Shipment? find(String query) {
    final q = query.trim().toUpperCase();
    for (final s in shipments) {
      if (s.id == q) return s;
    }
    return null;
  }

  void addShipment(Shipment s) {
    shipments.insert(0, s);
    notifications.insert(
        0, AppNotification('Shipment created', '${s.id} is ready for pickup.', 'now', Icons.add_box_rounded));
    notifyListeners();
  }

  List<ChatMessage> chatFor(Shipment s) => chats.putIfAbsent(
      s.id, () => [ChatMessage('Hi! I picked up your package, heading your way now 🚀', false)]);

  void send(Shipment s, String text) {
    chatFor(s).add(ChatMessage(text, true));
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1200), () {
      chatFor(s).add(ChatMessage(_reply(text), false));
      notifyListeners();
    });
  }

  String _reply(String t) {
    final l = t.toLowerCase();
    if (l.contains('where') || l.contains('how long')) return 'About ${shipments.first.eta} away, traffic is light 👍';
    if (l.contains('door') || l.contains('leave')) return 'Sure, I\'ll leave it at the door and send a photo.';
    if (l.contains('thank')) return 'You\'re welcome! Have a great day 😊';
    return 'Got it! I\'ll keep you updated.';
  }

  static String newTrackingId() {
    final n = DateTime.now().millisecondsSinceEpoch % 100000000;
    return 'V${n.toString().padLeft(8, '0')}';
  }

  static Courier get defaultCourier => _lina;
  static List<TrackingEvent> freshEvents() => _events(1);
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child}) : super(notifier: store);

  static AppStore of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
