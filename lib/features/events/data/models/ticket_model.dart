class TicketModel {
  final String id;
  final String eventId;
  final String name;
  final double price;
  final int totalCapacity;
  final int ticketsSold;

  const TicketModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.totalCapacity,
    required this.ticketsSold,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      totalCapacity: json['total_capacity'] as int,
      ticketsSold: json['tickets_sold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'name': name,
      'price': price,
      'total_capacity': totalCapacity,
      'tickets_sold': ticketsSold,
    };
  }
}
