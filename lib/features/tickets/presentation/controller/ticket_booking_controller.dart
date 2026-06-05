import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../events/data/models/ticket_model.dart';
import '../../data/repositories/ticket_repository_provider.dart';

part 'ticket_booking_controller.g.dart';

// 1. Upgraded your tiers fetcher to the modern Riverpod syntax
@riverpod
Future<List<TicketModel>> eventTiers(Ref ref, String eventId) async {
  // We use the injected Supabase client instead of the direct instance
  final client = ref.watch(supabaseProvider);

  final response = await client
      .from('ticket_tiers')
      .select()
      .eq('event_id', eventId)
      .order('price', ascending: true);

  return (response as List).map((json) => TicketModel.fromJson(json)).toList();
}

// 2. Upgraded your StateNotifier to the modern Notifier syntax
@riverpod
class TicketBookingController extends _$TicketBookingController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> bookTicket(String eventId, String ticketTierId) async {
    state = const AsyncLoading();

    try {
      // Get the injected Supabase client to check auth
      final client = ref.read(supabaseProvider);
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not Logged In');

      // Grab the worker (Repository) we built earlier
      final repository = ref.read(getTicketRepositoryProvider);

      // The repository handles the order number generation and the Supabase insertion!
      await repository.purchaseTicket(
        eventId: eventId,
        tierId: ticketTierId,
        attendeeId: user.id,
      );

      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}
