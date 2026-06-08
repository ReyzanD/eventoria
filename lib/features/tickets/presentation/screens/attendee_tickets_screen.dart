import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORT YOUR THEME ---
import '../../../../core/theme/attendee_theme.dart';
import '../controller/my_tickets_provider.dart';
import 'ticket_qr_screen.dart';

class AttendeeTicketsScreen extends ConsumerWidget {
  const AttendeeTicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the live database data
    final ticketsAsync = ref.watch(myTicketsControllerProvider);

    return Scaffold(
      backgroundColor: AttendeeTheme.bgColor, // Updated to Dark Theme
      appBar: AppBar(
        backgroundColor: AttendeeTheme.bgColor,
        elevation: 0,
        title: const Text(
          'My Tickets',
          style: TextStyle(
            color: Colors.white, // Updated
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AttendeeTheme.neonPink, // Updated
        backgroundColor: AttendeeTheme.cardColor,
        onRefresh: () =>
            ref.read(myTicketsControllerProvider.notifier).refresh(),
        child: ticketsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AttendeeTheme.electricBlue),
          ),
          error: (error, stack) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (tickets) {
            if (tickets.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No tickets yet',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your purchased tickets will appear here.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate directly to the QR screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketQrScreen(ticket: ticket),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AttendeeTheme.cardColor, // Updated to Dark Theme
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: ticket.isCheckedIn
                                ? Colors.greenAccent.withValues(alpha: 0.1)
                                : AttendeeTheme.electricBlue.withValues(
                                    alpha: 0.15,
                                  ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            ticket.isCheckedIn
                                ? Icons.check_circle
                                : Icons.confirmation_number,
                            color: ticket.isCheckedIn
                                ? Colors.greenAccent
                                : AttendeeTheme.electricBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.eventName ?? 'Unknown Event',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white, // Updated
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ticket.ticketTierName ?? 'General Admission',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ), // Updated
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order: ${ticket.orderNumber}',
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                ), // Updated
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white30,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
