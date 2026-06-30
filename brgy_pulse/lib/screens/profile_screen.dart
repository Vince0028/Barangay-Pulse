import 'package:flutter/material.dart';
import '../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: const Icon(Icons.person_rounded,
                  size: 40, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            Text('Guest User', style: tt.headlineSmall),
            const SizedBox(height: 2),
            Text('Not signed in', style: tt.bodyMedium),
            const SizedBox(height: 24),

            // Auth buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to sign in
                },
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to sign up
                },
                child: const Text('Create Account'),
              ),
            ),

            const SizedBox(height: 32),

            // Settings section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Settings', style: tt.headlineSmall),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Push Notifications',
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              trailing: Switch(
                value: true,
                onChanged: null, // Forced dark for now
                activeColor: AppColors.primary,
              ),
            ),

            const SizedBox(height: 32),

            // About section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('About', style: tt.headlineSmall),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'Version',
              trailing: Text('1.0.0', style: tt.bodyMedium),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.code_rounded,
              label: 'Built for SparkFest 2026',
              trailing: const SizedBox.shrink(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Reusable settings row
// ──────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: tt.titleMedium)),
            trailing,
          ],
        ),
      ),
    );
  }
}
