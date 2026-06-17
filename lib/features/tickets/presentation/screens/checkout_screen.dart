import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/attendee_theme.dart';
import '../../../events/data/models/event_model.dart';
import '../../../events/data/models/ticket_model.dart';
import '../../presentation/controller/ticket_booking_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final EventModel event;
  final TicketModel tier;

  const CheckoutScreen({
    super.key,
    required this.event,
    required this.tier,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _quantity = 1;
  bool _purchased = false;
  bool _paymentCreated = false;
  Map<String, dynamic>? _bankAccount;
  bool _loadingBank = true;

  @override
  void initState() {
    super.initState();
    _loadBankAccount();
  }

  Future<void> _loadBankAccount() async {
    try {
      final resp = await Supabase.instance.client
          .from('organizer_bank_accounts')
          .select()
          .eq('organizer_id', widget.event.organizerId)
          .maybeSingle();
      _bankAccount = resp;
    } catch (_) {}
    if (mounted) setState(() => _loadingBank = false);
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Future<void> _createPayment(String attendeeId, double amount) async {
    try {
      final client = Supabase.instance.client;
      await client.from('payments').insert({
        'event_id': widget.event.id,
        'attendee_id': attendeeId,
        'amount': amount,
        'status': 'pending',
        'payment_method': 'bank_transfer',
      });
      setState(() => _paymentCreated = true);
    } catch (e) {
      debugPrint('Failed to create payment record: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(ticketBookingControllerProvider);
    final isLoading = bookingState.isLoading;

    ref.listen<AsyncValue>(ticketBookingControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${next.error}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else if (next is AsyncData && !next.isLoading) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null && !_paymentCreated) {
          _createPayment(userId, widget.tier.price * _quantity);
        }
        setState(() => _purchased = true);
      }
    });

    final totalPrice = widget.tier.price * _quantity;
    final tier = widget.tier;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AttendeeTheme.bgColor,
      ),
      child: Scaffold(
        backgroundColor: AttendeeTheme.bgColor,
        appBar: AppBar(
          backgroundColor: AttendeeTheme.bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _purchased ? 'Payment Pending' : 'Checkout',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? 600 : double.infinity,
            ),
            child: _purchased
                ? _buildPendingView(totalPrice)
                : _buildCheckoutForm(isLoading, totalPrice, tier),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingView(double totalPrice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AttendeeTheme.neonOrange.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              size: 56,
              color: AttendeeTheme.neonOrange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Pending',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order has been placed. Complete the payment below.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AttendeeTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank Transfer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ..._bankDetailRows(),
                const SizedBox(height: 10),
                _bankRow('Amount', _formatCurrency(totalPrice)),
              ],
            ),
          ),
          if (_bankAccount == null && !_loadingBank)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AttendeeTheme.neonPink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AttendeeTheme.neonPink.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AttendeeTheme.neonPink, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The organizer hasn\'t set up their bank details yet. '
                        'Please contact them for payment instructions.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AttendeeTheme.neonOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AttendeeTheme.neonOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AttendeeTheme.neonOrange, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your booking is confirmed once the organizer verifies your payment.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AttendeeTheme.electricBlue,
                foregroundColor: AttendeeTheme.bgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () async {
                final uid = Supabase.instance.client.auth.currentUser?.id;
                if (uid != null) {
                  await Supabase.instance.client
                      .from('payments')
                      .update({'status': 'cancelled'})
                      .match({
                    'event_id': widget.event.id,
                    'attendee_id': uid,
                    'status': 'pending',
                  });
                }
                if (mounted) Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.cancel_outlined,
                color: AttendeeTheme.neonPink,
                size: 18,
              ),
              label: const Text(
                'Cancel Order',
                style: TextStyle(
                  color: AttendeeTheme.neonPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AttendeeTheme.neonPink),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Back to event',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bankDetailRows() {
    if (_loadingBank) {
      return [
        _bankRow('Bank', 'Loading...'),
        const SizedBox(height: 10),
        _bankRow('Account No.', 'Loading...'),
        const SizedBox(height: 10),
        _bankRow('Account Name', 'Loading...'),
      ];
    }
    if (_bankAccount != null) {
      return [
        _bankRow('Bank', _bankAccount!['bank_name'] ?? '-'),
        const SizedBox(height: 10),
        _bankRow('Account No.', _bankAccount!['account_number'] ?? '-'),
        const SizedBox(height: 10),
        _bankRow('Account Name', _bankAccount!['account_name'] ?? '-'),
      ];
    }
    return [
      _bankRow('Bank', 'Not yet set by organizer'),
      const SizedBox(height: 10),
      _bankRow('Account No.', '—'),
      const SizedBox(height: 10),
      _bankRow('Account Name', '—'),
    ];
  }

  Widget _bankRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutForm(bool isLoading, double totalPrice, TicketModel tier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AttendeeTheme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.event.coverImageUrl ??
                        'https://ui-avatars.com/api/?name=Event&background=161C2D&color=fff&size=400',
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 64,
                      width: 64,
                      color: AttendeeTheme.bgColor,
                      child: const Icon(Icons.image_outlined, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(widget.event.startDate),
                        style: const TextStyle(
                          color: AttendeeTheme.electricBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.event.venueName,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Ticket Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AttendeeTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AttendeeTheme.neonPink.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '${_formatCurrency(tier.price)} each',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(tier.price),
                  style: const TextStyle(
                    color: AttendeeTheme.neonPink,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quantity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _quantity > 1
                            ? AttendeeTheme.neonPink.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(Icons.remove_rounded,
                            color: _quantity > 1
                                ? AttendeeTheme.neonPink
                                : Colors.white24,
                            size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => setState(() => _quantity++),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AttendeeTheme.neonPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.add_rounded,
                            color: AttendeeTheme.neonPink, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tier.name} x $_quantity',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                _formatCurrency(tier.price * _quantity),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service fee',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              Text(
                'Free',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _formatCurrency(totalPrice),
                style: const TextStyle(
                  color: AttendeeTheme.neonOrange,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AttendeeTheme.electricBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AttendeeTheme.electricBlue.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded,
                    color: AttendeeTheme.electricBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Payment method: Bank Transfer (manual verification)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(ticketBookingControllerProvider.notifier)
                          .bookTicket(
                            widget.event.id,
                            tier.id,
                            quantity: _quantity,
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
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Pay ${_formatCurrency(totalPrice)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
