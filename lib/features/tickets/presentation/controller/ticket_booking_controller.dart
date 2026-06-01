import 'dart:math';
import 'package:eventoria/features/events/data/models/ticket_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final eventTiersProvider = FutureProvider.family
    .autoDispose<List<TicketModel>, String>((ref, eventId) async {
      final client = Supabase.instance.client;
      final response = await client
          .from('ticket_tiers')
          .select()
          .eq('event_id', eventId)
          .order('price', ascending: true);
      return (response as List)
          .map((json) => TicketModel.fromJson(json))
          .toList();
    });

final ticketBookingProvider =
    StateNotifierProvider.autoDispose<
      TicketBookingController,
      AsyncValue<void>
    >((ref) {
      return TicketBookingController();
    });

class TicketBookingController extends StateNotifier<AsyncValue<void>> {
  final _client = Supabase.instance.client;

  TicketBookingController() : super(const AsyncValue.data(null));

  Future<bool> bookTicket(String eventId, String ticketTierId) async {
    state = const AsyncValue.loading();
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not Logged In');

      final randomString = List.generate(
        6,
        (_) => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'[Random().nextInt(36)],
      ).join();
      final orderNumber = 'ORD-$randomString';

      await _client.from('tickets').insert({
        'ticket_tier_id': ticketTierId,
        'event_id': eventId,
        'attendee_id': user.id,
        'order_number': orderNumber,
      });

      state = const AsyncValue.data(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
