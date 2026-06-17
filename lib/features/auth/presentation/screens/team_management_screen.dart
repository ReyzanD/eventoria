import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamManagementScreen extends ConsumerStatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  ConsumerState<TeamManagementScreen> createState() =>
      _TeamManagementScreenState();
}

class _TeamManagementScreenState
    extends ConsumerState<TeamManagementScreen> {
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final resp = await Supabase.instance.client
          .from('team_members')
          .select('*, profiles(full_name, email, avatar_url)')
          .eq('organizer_id', user.id)
          .order('created_at', ascending: false);
      _members = (resp as List).cast<Map<String, dynamic>>();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _inviteMember() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('team_members').insert({
        'organizer_id': user.id,
        'email': email,
        'role': 'editor',
        'status': 'pending',
      });
      _emailController.clear();
      await _loadMembers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to $email'),
            backgroundColor: const Color(0xFF10B981),
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
    }
  }

  Future<void> _removeMember(String memberId) async {
    try {
      await Supabase.instance.client
          .from('team_members')
          .delete()
          .eq('id', memberId);
      await _loadMembers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        title: const Text(
          'Team Management',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invite a Team Member',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'colleague@example.com',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _inviteMember,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B4FEB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Invite',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  '${_members.length} ${_members.length == 1 ? 'Member' : 'Members'}',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                if (_members.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Center(
                      child: Text(
                        'No team members yet. Invite someone above.',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  )
                else
                  ..._members.map((m) {
                    final profile = m['profiles'] as Map<String, dynamic>?;
                    final name = profile?['full_name'] ?? m['email'];
                    final email = profile?['email'] ?? m['email'];
                    final status = m['status'] as String? ?? 'pending';
                    final isPending = status == 'pending';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isPending
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                : const Color(0xFF3B4FEB).withValues(alpha: 0.2),
                            child: Text(
                              (name as String).substring(0, 1),
                              style: TextStyle(
                                color: isPending
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF3B4FEB),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                                  : const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPending ? 'Pending' : 'Active',
                              style: TextStyle(
                                color: isPending
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF059669),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            onPressed: () => _removeMember(m['id'] as String),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
