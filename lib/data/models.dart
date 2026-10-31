import 'package:flutter/material.dart';

enum ShipmentStatus { pending, packed, inTransit, outForDelivery, delivered }

extension ShipmentStatusX on ShipmentStatus {
  String get label => switch (this) {
        ShipmentStatus.pending => 'Pending',
        ShipmentStatus.packed => 'Packed',
        ShipmentStatus.inTransit => 'In transit',
        ShipmentStatus.outForDelivery => 'On the way',
        ShipmentStatus.delivered => 'Delivered',
      };

  IconData get icon => switch (this) {
        ShipmentStatus.pending => Icons.schedule_rounded,
        ShipmentStatus.packed => Icons.inventory_2_rounded,
        ShipmentStatus.inTransit => Icons.local_shipping_rounded,
        ShipmentStatus.outForDelivery => Icons.delivery_dining_rounded,
        ShipmentStatus.delivered => Icons.verified_rounded,
      };

  /// 0..4 position on the progress stepper.
  int get step => index;
}

class Courier {
  final String name;
  final String vehicle;
  final double rating;
  final Color avatarColor;
  const Courier(this.name, this.vehicle, this.rating, this.avatarColor);

  String get initials => name.split(' ').map((e) => e[0]).take(2).join();
}

class TrackingEvent {
  final String title;
  final String place;
  final String time;
  final bool done;
  const TrackingEvent(this.title, this.place, this.time, this.done);
}

class Shipment {
  final String id;
  final String title;
  final String from;
  final String to;
  final String fromShort;
  final String toShort;
  final double price;
  final double weightKg;
  final String customer;
  final ShipmentStatus status;
  final String eta;
  final Courier courier;
  final List<TrackingEvent> events;
  final Color boxTint;
  bool favorite;

  Shipment({
    required this.id,
    required this.title,
    required this.from,
    required this.to,
    required this.fromShort,
    required this.toShort,
    required this.price,
    required this.weightKg,
    required this.customer,
    required this.status,
    required this.eta,
    required this.courier,
    required this.events,
    this.boxTint = const Color(0xFFD9A066),
    this.favorite = false,
  });
}

class ChatMessage {
  final String text;
  final bool mine;
  final DateTime time;
  ChatMessage(this.text, this.mine) : time = DateTime.now();
}

class AppNotification {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  bool read;
  AppNotification(this.title, this.body, this.time, this.icon, {this.read = false});
}
