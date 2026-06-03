import 'event_sales_summary.dart';
import '../../../events/data/models/event_model.dart';

class DashboardViewState {
  final List<EventSalesSummary> allEvents;
  final List<EventSalesSummary> liveEvents;
  final List<EventSalesSummary> draftEvents;
  final List<EventSalesSummary> pastEvents;
  final EventModel? nextEvent;
  final double totalRevenue;
  final int totalTicketsSold;
  final double conversionRate;

  DashboardViewState({
    required this.allEvents,
    required this.liveEvents,
    required this.draftEvents,
    required this.pastEvents,
    this.nextEvent,
    required this.totalRevenue,
    required this.totalTicketsSold,
    required this.conversionRate,
  });
}
