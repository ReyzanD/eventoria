import 'package:eventoria/features/attendees/data/repositories/attendee_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/profile_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/controller/organizer_dashboard_controller.dart';
import '../../domain/entities/organizer_attendee_entity.dart';

part 'organizer_all_attendees_provider.g.dart';

class OrganizerAllAttendeeItem {
  final OrganizerAttendeeEntity attendee;
  final String eventId;
  final String eventTitle;

  const OrganizerAllAttendeeItem({
    required this.attendee,
    required this.eventId,
    required this.eventTitle,
  });
}

@riverpod
class OrganizerAllAttendeesController
    extends _$OrganizerAllAttendeesController {
  @override
  Future<List<OrganizerAllAttendeeItem>> build() async {
    final profile = await ref.watch(authControllerProvider.future);

    if (profile == null || profile.role != UserRole.organizer) {
      return [];
    }

    final dashboardState = await ref.watch(organizerDashboardProvider.future);
    final attendeesRepository = ref.watch(getAttendeeRepositoryProvider);

    final allEvents = [
      ...dashboardState.liveEvents,
      ...dashboardState.draftEvents,
      ...dashboardState.pastEvents,
    ];

    if (allEvents.isEmpty) {
      return [];
    }

    final allItems = <OrganizerAllAttendeeItem>[];

    for (final eventSummary in allEvents) {
      final eventId = eventSummary.event.id;
      final eventTitle = eventSummary.event.title;

      final attendees = await attendeesRepository.getEventAttendees(eventId);

      for (final attendee in attendees) {
        allItems.add(
          OrganizerAllAttendeeItem(
            attendee: attendee,
            eventId: eventId,
            eventTitle: eventTitle,
          ),
        );
      }
    }

    allItems.sort(
      (a, b) => a.attendee.name.toLowerCase().compareTo(
        b.attendee.name.toLowerCase(),
      ),
    );

    return allItems;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
