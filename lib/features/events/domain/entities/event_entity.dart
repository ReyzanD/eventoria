class EventEntity {
  final String id;
  final String organizerId;
  final String title;
  final String? description;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String venueName;
  final double latitude; // Matches your exact model types
  final double longitude; // Matches your exact model types
  final String? coverImageUrl;
  final bool isPublished;
  final bool allowRefunds;
  final DateTime createdAt;

  const EventEntity({
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
}
