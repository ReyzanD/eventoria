import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/data/models/event_model.dart';
import '../../../tickets/presentation/controller/ticket_booking_controller.dart';
import '../../../tickets/presentation/screens/checkout_screen.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final EventModel event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  String? _selectedTierId;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minutes = date.minute.toString().padLeft(2, '0');

    return '$dayName, $monthName ${date.day} • $hour:$minutes $amPm';
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(ticketBookingControllerProvider).isLoading;

    // Fetch the ticket tiers from the database
    final tiersAsync = ref.watch(eventTiersProvider(widget.event.id));

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 900 : double.infinity,
            ),
            child: CustomScrollView(
          slivers: [
            // --- HUGE HERO IMAGE APP BAR ---
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: AttendeeTheme.bgColor,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: BackButton(color: Colors.white),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      // Replace with widget.event.imageUrl if you have it!
                      'https://ui-avatars.com/api/?name=Event&background=3B4FEB&color=fff',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AttendeeTheme.bgColor],
                          stops: [0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- EVENT DETAILS ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date & Location Info Rows
                    _buildInfoRow(
                      Icons.calendar_month_rounded,
                      _formatDate(widget.event.startDate),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.location_on_rounded,
                      widget.event.venueName,
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'About this event',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      // Replace with widget.event.description if available
                      'Join us for an amazing experience! Grab your tickets below before they sell out.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      'Select Ticket Tier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- TICKET TIERS SELECTOR ---
                    tiersAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: AttendeeTheme.neonPink,
                        ),
                      ),
                      error: (err, stack) => Text(
                        'Error loading tickets: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                      data: (tiers) {
                        if (tiers.isEmpty) {
                          return const Text(
                            'Tickets are not available yet.',
                            style: TextStyle(color: Colors.grey),
                          );
                        }
                        return Column(
                          children: tiers.map((tier) {
                            final isSelected = _selectedTierId == tier.id;
                            final isSoldOut =
                                tier.ticketsSold >= tier.totalCapacity;

                            return GestureDetector(
                              onTap: isSoldOut
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedTierId = tier.id;
                                      });
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AttendeeTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AttendeeTheme.neonPink
                                        : Colors.white.withValues(alpha: 0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tier.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isSoldOut
                                              ? 'Sold Out'
                                              : '${tier.totalCapacity - tier.ticketsSold} left',
                                          style: TextStyle(
                                            color: isSoldOut
                                                ? Colors.redAccent
                                                : Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatCurrency(tier.price),
                                      style: TextStyle(
                                        color: isSelected
                                            ? AttendeeTheme.neonPink
                                            : Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 100), // Padding for bottom bar
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),

        // --- STICKY BOTTOM BUY BUTTON ---
        bottomSheet: Container(
          color: AttendeeTheme.bgColor,
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 32,
            top: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_selectedTierId == null || isLoading)
                  ? null
                  : () {
                      final currentUserId = ref
                          .read(authControllerProvider)
                          .value
                          ?.id;
                      if (currentUserId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please log in first!')),
                        );
                        return;
                      }

                      final tiers = tiersAsync.asData?.value;
                      if (tiers == null) return;
                      final selectedTier = tiers.firstWhere((t) => t.id == _selectedTierId);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            event: widget.event,
                            tier: selectedTier,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AttendeeTheme.neonPink,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _selectedTierId == null
                          ? 'Select a Ticket'
                          : 'Buy Ticket',
                      style: TextStyle(
                        color: _selectedTierId == null
                            ? Colors.white54
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AttendeeTheme.electricBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
