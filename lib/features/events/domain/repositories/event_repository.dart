import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<Either<Failure, List<EventEntity>>> fetchPublishedEvents();
  Stream<List<EventEntity>> streamOrganizerEventsRealtime(String organizerId);
}
