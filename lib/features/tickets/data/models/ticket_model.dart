import '../../domain/entities/ticket_entity.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.ticketTierId,
    required super.eventId,
    required super.attendeeId,
    required super.orderNumber,
    super.section,
    super.rowName,
    super.seatNumber,
    required super.isCheckedIn,
    super.checkedInAt,
    required super.createdAt,
    super.eventName,
    super.ticketTierName,
    super.paymentStatus,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketTierId: json['ticket_tier_id'] as String,
      eventId: json['event_id'] as String,
      attendeeId: json['attendee_id'] as String,
      orderNumber: json['order_number'] as String,
      section: json['section'] as String?,
      rowName: json['row_name'] as String?,
      seatNumber: json['seat_number'] as String?,
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] != null
          ? DateTime.parse(json['checked_in_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      eventName: json['events']?['title'] as String?,
      ticketTierName: json['ticket_tiers']?['name'] as String?,
    );
  }
}
