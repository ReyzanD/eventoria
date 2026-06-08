import '../entities/ticket_entity.dart';

abstract class TicketRepository {
  Future<TicketEntity> purchaseTicket({
    required String eventId,
    required String tierId,
    required String attendeeId,
  });

  Future<List<TicketEntity>> getMyTickets(String attendeeId);
  Future<void> checkInTicket(String ticketId);
}
