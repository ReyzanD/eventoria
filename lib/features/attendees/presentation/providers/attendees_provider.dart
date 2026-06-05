import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/organizer_attendee_entity.dart';
import '../../data/repositories/attendee_repository_provider.dart';

part 'attendees_provider.g.dart';

class AttendeesState {
  final List<OrganizerAttendeeEntity> allAttendees;
  final String searchQuery;
  final int selectedFilterIndex;
  final bool isLoading;
  final String? errorMessage;

  AttendeesState({
    required this.allAttendees,
    this.searchQuery = '',
    this.selectedFilterIndex = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  AttendeesState copyWith({
    List<OrganizerAttendeeEntity>? allAttendees,
    String? searchQuery,
    int? selectedFilterIndex,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AttendeesState(
      allAttendees: allAttendees ?? this.allAttendees,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<OrganizerAttendeeEntity> get filteredAttendees {
    final query = searchQuery.trim().toLowerCase();
    return allAttendees.where((attendee) {
      final matchesSearch =
          query.isEmpty ||
          attendee.name.toLowerCase().contains(query) ||
          attendee.email.toLowerCase().contains(query) ||
          attendee.eventName.toLowerCase().contains(query) ||
          attendee.ticketType.toLowerCase().contains(query) ||
          attendee.orderCode.toLowerCase().contains(query);

      final matchesFilter = switch (selectedFilterIndex) {
        0 => true,
        1 => attendee.checkedIn,
        2 => !attendee.checkedIn,
        3 => attendee.isVip,
        _ => true,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }
}

@riverpod
class AttendeesController extends _$AttendeesController {
  @override
  AttendeesState build(String eventId) {
    debugPrint('AttendeesController.build called');
    debugPrint('build eventId = $eventId');

    Future.microtask(() => _fetchAttendees(eventId));

    return AttendeesState(allAttendees: const [], isLoading: true);
  }

  Future<void> _fetchAttendees(String eventId) async {
    debugPrint('_fetchAttendees called');
    debugPrint('_fetchAttendees eventId = $eventId');

    try {
      final repository = ref.read(getAttendeeRepositoryProvider);
      debugPrint('repository resolved = $repository');

      final realAttendees = await repository.getEventAttendees(eventId);
      debugPrint('realAttendees length = ${realAttendees.length}');

      state = state.copyWith(allAttendees: realAttendees, isLoading: false);
    } catch (e, stackTrace) {
      debugPrint('Error fetching attendees: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilterIndex(int index) {
    state = state.copyWith(selectedFilterIndex: index);
  }

  Future<void> retry() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetchAttendees(eventId);
  }
}
