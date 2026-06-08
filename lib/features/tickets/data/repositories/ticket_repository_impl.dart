import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/entities/ticket_entity.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final SupabaseClient _supabase;

  TicketRepositoryImpl(this._supabase);

  @override
  Future<TicketEntity> purchaseTicket({
    required String eventId,
    required String tierId,
    required String attendeeId,
  }) async {
    try {
      final String orderNumber = _generateOrderNumber();

      final response = await _supabase
          .from('tickets')
          .insert({
            'ticket_tier_id': tierId,
            'event_id': eventId,
            'attendee_id': attendeeId,
            'order_number': orderNumber,
            'is_checked_in': false,
          })
          .select()
          .single();

      final tierData = await _supabase
          .from('ticket_tiers')
          .select('tickets_sold')
          .eq('id', tierId)
          .single();
      final currentSold = tierData['tickets_sold'] as int;

      await _supabase
          .from('ticket_tiers')
          .update({'tickets_sold': currentSold + 1})
          .eq('id', tierId);

      // 4. Return the parsed model
      return TicketModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to purchase ticket: $e');
    }
  }

  @override
  Future<List<TicketEntity>> getMyTickets(String attendeeId) async {
    try {
      final List<dynamic> response = await _supabase
          .from('tickets')
          .select('*, events(title), ticket_tiers(name)')
          .eq('attendee_id', attendeeId)
          .order('created_at', ascending: false);

      return response
          .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch your tickets: $e');
    }
  }

  String _generateOrderNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    final randomString = String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    return 'ORD-$randomString';
  }

  @override
  Future<void> checkInTicket(String ticketId) async {
    try {
      final ticket = await _supabase
          .from('tickets')
          .select('is_checked_in')
          .eq('id', ticketId)
          .single();

      if (ticket['is_checked_in'] == true) {
        throw Exception('This ticket has already been checked in!');
      }

      await _supabase
          .from('tickets')
          .update({
            'is_checked_in': true,
            'checked_in_at': DateTime.now().toIso8601String(),
          })
          .eq('id', ticketId);
    } catch (e) {
      throw Exception('Scan failed: $e');
    }
  }
}
