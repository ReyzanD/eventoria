class OrganizerAttendeeEntity {
  final String id;
  final String name;
  final String email;
  final String eventName;
  final String ticketType;
  final bool checkedIn;
  final bool isVip;
  final String orderCode;

  const OrganizerAttendeeEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.eventName,
    required this.ticketType,
    required this.checkedIn,
    required this.isVip,
    required this.orderCode,
  });
}
