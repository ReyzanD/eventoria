import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';

final organizerPaymentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(supabaseProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  final eventIdsRaw = await client
      .from('events')
      .select('id')
      .eq('organizer_id', userId);

  final eventIds = (eventIdsRaw as List)
      .map((e) => e['id'] as String)
      .toList();

  if (eventIds.isEmpty) return [];

  final response = await client
      .from('payments')
      .select('*, events(title), profiles(full_name, email)')
      .inFilter('event_id', eventIds)
      .order('created_at', ascending: false);

  return (response as List).cast<Map<String, dynamic>>();
});

class OrganizerPaymentsScreen extends ConsumerWidget {
  const OrganizerPaymentsScreen({super.key});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(organizerPaymentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Payment Verification',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
      ),
      body: paymentsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
        ),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_rounded,
                      size: 64, color: const Color(0xFF717F8C).withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No payments yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Payments from ticket purchases will appear here.',
                    style: TextStyle(color: Color(0xFF717F8C)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final p = payments[index];
              final status = p['status'] as String? ?? 'pending';
              final amount = (p['amount'] as num?)?.toDouble() ?? 0;
              final eventTitle =
                  (p['events'] as Map<String, dynamic>?)?['title'] as String? ??
                      'Unknown Event';
              final profileData = p['profiles'] as Map<String, dynamic>?;
              final attendeeName = profileData?['full_name'] as String? ?? 'Unknown';
              final attendeeEmail = profileData?['email'] as String? ?? '';
              final createdAt = p['created_at'] as String? ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            eventTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'confirmed'
                                ? Colors.green.withValues(alpha: 0.1)
                                : status == 'failed'
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: status == 'confirmed'
                                  ? Colors.green.shade700
                                  : status == 'failed'
                                      ? Colors.red
                                      : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 16, color: Color(0xFF717F8C)),
                        const SizedBox(width: 6),
                        Text(
                          attendeeName,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                    if (attendeeEmail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined,
                              size: 16, color: Color(0xFF717F8C)),
                          const SizedBox(width: 6),
                          Text(
                            attendeeEmail,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 16, color: Color(0xFF717F8C)),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(createdAt),
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatCurrency(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (status == 'pending')
                          ElevatedButton(
                            onPressed: () =>
                                _confirmPayment(context, ref, p['id'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B4FEB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'Confirm Payment',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmPayment(
      BuildContext context, WidgetRef ref, String paymentId) async {
    try {
      final client = Supabase.instance.client;

      final paymentData = await client
          .from('payments')
          .select('*, events(title, organizer_id)')
          .eq('id', paymentId)
          .single();

      final eventTitle =
          (paymentData['events'] as Map<String, dynamic>?)?['title'] as String? ??
              'Event';
      final attendeeId = paymentData['attendee_id'] as String?;

      await client
          .from('payments')
          .update({
            'status': 'confirmed',
            'confirmed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);

      if (attendeeId != null) {
        await client.from('notifications').insert({
          'user_id': attendeeId,
          'title': 'Payment Confirmed',
          'body': 'Your payment for "$eventTitle" has been confirmed! 🎉',
          'type': 'payment_confirmed',
          'related_id': paymentId,
        });
      }

      ref.invalidate(organizerPaymentsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed! Attendee has been notified.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
