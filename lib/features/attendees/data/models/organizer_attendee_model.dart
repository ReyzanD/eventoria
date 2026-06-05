import '../../domain/entities/organizer_attendee_entity.dart';

class OrganizerAttendeeModel extends OrganizerAttendeeEntity {
  const OrganizerAttendeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.eventName,
    required super.ticketType,
    required super.checkedIn,
    required super.isVip,
    required super.orderCode,
  });

  // The "Translator" function. It takes messy JSON and outputs a clean Model.
  factory OrganizerAttendeeModel.fromJson(Map<String, dynamic> json) {
    // 1. Extract the nested tables from the Supabase join safely
    final profile = json['profiles'] as Map<String, dynamic>? ?? {};
    final event = json['events'] as Map<String, dynamic>? ?? {};
    final tier = json['ticket_tiers'] as Map<String, dynamic>? ?? {};

    // 2. Extract the tier name to determine VIP status
    final tierName = tier['name'] as String? ?? 'General';

    // 3. Map the raw database columns to our clean Entity properties
    return OrganizerAttendeeModel(
      id: json['id'] as String? ?? '',
      name: profile['full_name'] as String? ?? 'Unknown Attendee',
      email: profile['email'] as String? ?? 'No email',
      eventName: event['title'] as String? ?? 'Unknown Event',
      ticketType: tierName,
      checkedIn: json['is_checked_in'] as bool? ?? false,

      // We derive "isVip" based on the ticket tier name
      isVip: tierName.toLowerCase().contains('vip'),

      orderCode: json['order_number'] as String? ?? '',
    );
  }
}
