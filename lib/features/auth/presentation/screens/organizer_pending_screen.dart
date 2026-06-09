import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class OrganizerPendingScreen extends ConsumerWidget {
  const OrganizerPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 64,
                  color: Color(0xFF3B4FEB),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Account Under Review',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To keep our community safe, all organizer accounts must be verified by our team before publishing events. We will review your account shortly!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // A button to refresh their profile to see if they got approved
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Trigger a refresh of the auth provider to pull new database status
                    ref.invalidate(authControllerProvider);
                  },
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text(
                    'Check Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B4FEB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref
                      .read(authControllerProvider.notifier)
                      .logout(
                        onError: (err) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sign out failed: $err'),
                              backgroundColor: const Color(0xFFF45E65),
                            ),
                          );
                        },
                      );
                },
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFF45E65),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
