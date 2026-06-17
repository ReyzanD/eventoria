class TicketEntity {
  final String id;
  final String ticketTierId;
  final String eventId;
  final String attendeeId;
  final String orderNumber;
  final String? section;
  final String? rowName;
  final String? seatNumber;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final DateTime createdAt;
  final String? eventName;
  final String? ticketTierName;
  final String? paymentStatus;

  const TicketEntity({
    required this.id,
    required this.ticketTierId,
    required this.eventId,
    required this.attendeeId,
    required this.orderNumber,
    this.section,
    this.rowName,
    this.seatNumber,
    required this.isCheckedIn,
    this.checkedInAt,
    required this.createdAt,
    this.eventName,
    this.ticketTierName,
    this.paymentStatus,
  });
}
