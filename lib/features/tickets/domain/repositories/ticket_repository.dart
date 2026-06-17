import '../entities/ticket_entity.dart';

abstract class TicketRepository {
  Future<List<TicketEntity>> purchaseTicket({
    required String eventId,
    required String tierId,
    required String attendeeId,
    int quantity = 1,
  });

  Future<List<TicketEntity>> getMyTickets(String attendeeId);
  Future<void> checkInTicket(String ticketId);
}
