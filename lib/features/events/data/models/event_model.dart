import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  EventModel();
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel();
}
