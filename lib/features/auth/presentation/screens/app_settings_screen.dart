import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _paymentAlerts = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1E293B)),
        title: const Text(
          'App Settings',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Notifications'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                subtitle: 'Receive alerts for new payments and check-ins',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _SwitchTile(
                icon: Icons.email_rounded,
                label: 'Email Notifications',
                subtitle: 'Get email updates for daily summaries',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _SwitchTile(
                icon: Icons.payments_rounded,
                label: 'Payment Alerts',
                subtitle: 'Be notified when a payment is confirmed',
                value: _paymentAlerts,
                onChanged: (v) => setState(() => _paymentAlerts = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Appearance'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _InfoTile(icon: Icons.info_outline_rounded, label: 'Version', value: '1.0.0'),
              const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
              _InfoTile(icon: Icons.code_rounded, label: 'Build', value: '2026.06.15'),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Eventoria v1.0.0',
              style: TextStyle(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF3B4FEB).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B4FEB), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      ),
      trailing: Switch(
        value: value,
        activeThumbColor: const Color(0xFF3B4FEB),
        onChanged: onChanged,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF64748B).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF64748B), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 15,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
