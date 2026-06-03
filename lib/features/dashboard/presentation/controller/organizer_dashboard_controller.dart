import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/data/models/ticket_model.dart';
import '../../domain/models/dashboard_view_state.dart';
import '../../domain/models/event_sales_summary.dart';

final organizerDashboardProvider =
    FutureProvider.autoDispose<DashboardViewState>((ref) async {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not logged in');

      final response = await client
          .from('events')
          .select('*, ticket_tiers(*)')
          .eq('organizer_id', user.id)
          .order('created_at', ascending: false);


      final summaries = (response as List).map((json) {
        final event = EventModel.fromJson(json);
        final tiersJson = json['ticket_tiers'] as List? ?? [];
        final tiers = tiersJson.map((t) => TicketModel.fromJson(t)).toList();

        int sold = 0;
        int capacity = 0;
        double revenue = 0.0;

        for (var tier in tiers) {
          sold += tier.ticketsSold;
          capacity += tier.totalCapacity;
          revenue += (tier.ticketsSold * tier.price);
        }

        return EventSalesSummary(
          event: event,
          tiers: tiers,
          totalSold: sold,
          totalCapacity: capacity,
          totalRevenue: revenue,
        );
      }).toList();

      double totalRevenue = 0;
      int totalTicketsSold = 0;
      final now = DateTime.now();

      final List<EventSalesSummary> liveEvents = [];
      final List<EventSalesSummary> draftEvents = [];
      final List<EventSalesSummary> pastEvents = [];

      for (final summary in summaries) {
        totalRevenue += summary.totalRevenue;
        totalTicketsSold += summary.totalSold;

        if (!summary.event.isPublished) {
          draftEvents.add(summary);
        } else if (summary.event.endDate.isBefore(now)) {
          pastEvents.add(summary);
        } else {
          liveEvents.add(summary);
        }
      }

      final double conversionRate = totalTicketsSold == 0
          ? 0.0
          : (totalTicketsSold / (totalTicketsSold * 10 + 20) * 100).clamp(
              3.0,
              15.0,
            );

      EventModel? nextEvent;
      if (liveEvents.isNotEmpty) {
        final sortedLive = List<EventSalesSummary>.from(liveEvents)
          ..sort((a, b) => a.event.startDate.compareTo(b.event.startDate));
        nextEvent = sortedLive.first.event;
      }

      return DashboardViewState(
        allEvents: summaries,
        liveEvents: liveEvents,
        draftEvents: draftEvents,
        pastEvents: pastEvents,
        nextEvent: nextEvent,
        totalRevenue: totalRevenue,
        totalTicketsSold: totalTicketsSold,
        conversionRate: conversionRate,
      );
    });
