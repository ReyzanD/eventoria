import '../../domain/entities/event_entity.dart';
import 'ticket_model.dart';

class EventModel extends EventEntity {
  EventModel({
    required super.id,
    required super.organizerId,
    required super.title,
    super.description,
    required super.category,
    required super.startDate,
    required super.endDate,
    required super.venueName,
    required super.latitude,
    required super.longitude,
    super.coverImageUrl,
    required super.isPublished,
    required super.allowRefunds,
    required super.createdAt,
    super.ticketTiers,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      organizerId: json['organizer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      venueName: json['venue_name'] as String,
      // Safe casting fallback in case a row returns null from postgres column parameters
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : 0.0,
      coverImageUrl: json['cover_image_url'] as String?,
      isPublished: json['is_published'] as bool,
      allowRefunds: json['allow_refunds'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      ticketTiers: json['ticket_tiers'] != null
          ? (json['ticket_tiers'] as List)
              .map((tierJson) => TicketModel.fromJson(tierJson))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizer_id': organizerId,
      'title': title,
      'description': description,
      'category': category,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'venue_name': venueName,
      'latitude': latitude,
      'longitude': longitude,
      'cover_image_url': coverImageUrl,
      'is_published': isPublished,
      'allow_refunds': allowRefunds,
    };
  }
}
