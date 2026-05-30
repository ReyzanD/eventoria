class EventModel {
  final String id;
  final String organizerId;
  final String title;
  final String? description;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String venueName;
  final double latitude;
  final double longitude;
  final String? coverImageUrl;
  final bool isPublished;
  final bool allowRefunds;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.venueName,
    required this.latitude,
    required this.longitude,
    this.coverImageUrl,
    required this.isPublished,
    required this.allowRefunds,
    required this.createdAt,
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
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      coverImageUrl: json['cover_image_url'] as String?,
      isPublished: json['is_published'] as bool,
      allowRefunds: json['allow_refunds'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
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
