import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

class OrganizationDetailsScreen extends ConsumerStatefulWidget {
  const OrganizationDetailsScreen({super.key});

  @override
  ConsumerState<OrganizationDetailsScreen> createState() =>
      _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState
    extends ConsumerState<OrganizationDetailsScreen> {
  final _orgNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrg();
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadOrg() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final resp = await Supabase.instance.client
          .from('organizer_profiles')
          .select()
          .eq('organizer_id', user.id)
          .maybeSingle();

      if (resp != null) {
        final data = resp;
        _orgNameController.text = data['org_name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        _websiteController.text = data['website'] ?? '';
        _phoneController.text = data['phone'] ?? '';
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    setState(() => _isSaving = true);
    try {
      final payload = {
        'organizer_id': user.id,
        'org_name': _orgNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'website': _websiteController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      final existing = await Supabase.instance.client
          .from('organizer_profiles')
          .select('organizer_id')
          .eq('organizer_id', user.id)
          .maybeSingle();

      if (existing != null) {
        await Supabase.instance.client
            .from('organizer_profiles')
            .update(payload)
            .eq('organizer_id', user.id);
      } else {
        await Supabase.instance.client
            .from('organizer_profiles')
            .insert(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organization details saved!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.of(context).pop();
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        title: const Text(
          'Organization Details',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF3B4FEB),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF3B4FEB),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B4FEB)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFF3B4FEB),
                        child: Text(
                          (profile?.fullName ?? 'O').substring(0, 1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B4FEB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white, size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _Field(
                  controller: _orgNameController,
                  label: 'Organization Name',
                  hint: 'e.g. Eventoria Events',
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Tell attendees about your organization...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _websiteController,
                  label: 'Website',
                  hint: 'https://example.com',
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+62 812 3456 7890',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int? maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B4FEB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14,
        ),
      ),
    );
  }
}
