import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrganizerPayoutsScreen extends ConsumerStatefulWidget {
  const OrganizerPayoutsScreen({super.key});

  @override
  ConsumerState<OrganizerPayoutsScreen> createState() =>
      _OrganizerPayoutsScreenState();
}

class _OrganizerPayoutsScreenState
    extends ConsumerState<OrganizerPayoutsScreen> {
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _isSavingBank = false;
  double _totalRevenue = 0;
  double _pendingPayout = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _bankAccount;

  String _fmt(double v) =>
      NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0).format(v);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final events = await Supabase.instance.client
          .from('events')
          .select('id')
          .eq('organizer_id', user.id);
      final eventIds = (events as List).map((e) => e['id'] as String).toList();

      if (eventIds.isNotEmpty) {
        final confirmed = await Supabase.instance.client
            .from('payments')
            .select('amount')
            .inFilter('event_id', eventIds)
            .eq('status', 'confirmed');
        _totalRevenue = (confirmed as List)
            .fold<double>(0, (sum, p) => sum + (p['amount'] as num).toDouble());

        final pending = await Supabase.instance.client
            .from('payments')
            .select('amount')
            .inFilter('event_id', eventIds)
            .eq('status', 'pending');
        _pendingPayout = (pending as List)
            .fold<double>(0, (sum, p) => sum + (p['amount'] as num).toDouble());
      }

      final bankResp = await Supabase.instance.client
          .from('organizer_bank_accounts')
          .select()
          .eq('organizer_id', user.id)
          .maybeSingle();
      _bankAccount = bankResp;
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveBankAccount() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _isSavingBank = true);
    try {
      final payload = {
        'organizer_id': user.id,
        'bank_name': _bankNameController.text.trim(),
        'account_name': _accountNameController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
      };
      if (_bankAccount != null) {
        await Supabase.instance.client
            .from('organizer_bank_accounts')
            .update(payload)
            .eq('organizer_id', user.id);
      } else {
        await Supabase.instance.client
            .from('organizer_bank_accounts')
            .insert(payload);
      }
      await _loadStats();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account saved!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingBank = false);
    }
  }

  void _showBankAccountDialog() {
    if (_bankAccount != null) {
      _bankNameController.text = _bankAccount!['bank_name'] ?? '';
      _accountNameController.text = _bankAccount!['account_name'] ?? '';
      _accountNumberController.text = _bankAccount!['account_number'] ?? '';
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bank Account',
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSavingBank ? null : _saveBankAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B4FEB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSavingBank
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white,
                        ),
                      )
                    : const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _mockPayoutHistory() {
    return [
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'amount': 1500000.0,
        'status': 'completed',
        'ref': 'PO-20260612-A',
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'amount': 750000.0,
        'status': 'completed',
        'ref': 'PO-20260605-B',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final payouts = _mockPayoutHistory();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        title: const Text(
          'Payouts & Bank Info',
          style: TextStyle(
            color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B4FEB)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Revenue',
                        value: _fmt(_totalRevenue),
                        icon: Icons.trending_up_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Pending Payout',
                        value: _fmt(_pendingPayout),
                        icon: Icons.schedule_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8,
                    ),
                    leading: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Color(0xFF3B4FEB),
                      ),
                    ),
                    title: Text(
                      _bankAccount != null
                          ? '${_bankAccount!['bank_name']} — ${_bankAccount!['account_number']}'
                          : 'No bank account linked',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: _bankAccount != null
                        ? Text(
                            _bankAccount!['account_name'] ?? '',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          )
                        : null,
                    trailing: const Icon(
                      Icons.edit_rounded, color: Color(0xFF94A3B8), size: 20,
                    ),
                    onTap: _showBankAccountDialog,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Payout History',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                ...payouts.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fmt(p['amount'] as double),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p['ref'] as String,
                              style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d').format(p['date'] as DateTime),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 22, color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
