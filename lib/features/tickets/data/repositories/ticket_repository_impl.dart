import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../../domain/entities/ticket_entity.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final SupabaseClient _supabase;

  TicketRepositoryImpl(this._supabase);

  @override
  Future<List<TicketEntity>> purchaseTicket({
    required String eventId,
    required String tierId,
    required String attendeeId,
    int quantity = 1,
  }) async {
    try {
      final tierData = await _supabase
          .from('ticket_tiers')
          .select('tickets_sold, total_capacity')
          .eq('id', tierId)
          .single();
      final currentSold = tierData['tickets_sold'] as int;
      final available = tierData['total_capacity'] as int? ?? currentSold;
      if (currentSold + quantity > available) {
        throw Exception('Not enough tickets available');
      }

      final List<TicketEntity> tickets = [];
      for (int i = 0; i < quantity; i++) {
        final orderNumber = _generateOrderNumber();
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
        tickets.add(TicketModel.fromJson(response));
      }

      await _supabase
          .from('ticket_tiers')
          .update({'tickets_sold': currentSold + quantity})
          .eq('id', tierId);

      return tickets;
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

      final tickets = response
          .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final paymentStatuses = await _supabase
          .from('payments')
          .select('event_id, status')
          .eq('attendee_id', attendeeId)
          .inFilter('status', ['pending', 'confirmed', 'failed', 'cancelled']);

      final statusMap = <String, String>{};
      for (final p in paymentStatuses as List) {
        final eid = p['event_id'] as String;
        final st = p['status'] as String;
        if (!statusMap.containsKey(eid)) {
          statusMap[eid] = st;
        }
      }

      return tickets.map((t) {
        final status = statusMap[t.eventId] ?? 'pending';
        return TicketModel(
          id: t.id,
          ticketTierId: t.ticketTierId,
          eventId: t.eventId,
          attendeeId: t.attendeeId,
          orderNumber: t.orderNumber,
          section: t.section,
          rowName: t.rowName,
          seatNumber: t.seatNumber,
          isCheckedIn: t.isCheckedIn,
          checkedInAt: t.checkedInAt,
          createdAt: t.createdAt,
          eventName: t.eventName,
          ticketTierName: t.ticketTierName,
          paymentStatus: status,
        );
      }).toList();
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
