import '../../../events/data/models/event_model.dart';
import '../../../events/data/models/ticket_model.dart';

class EventSalesSummary {
  final EventModel event;
  final List<TicketModel> tiers;
  final int totalSold;
  final int totalCapacity;
  final double totalRevenue;

  EventSalesSummary({
    required this.event,
    required this.tiers,
    required this.totalSold,
    required this.totalCapacity,
    required this.totalRevenue,
  });
}
