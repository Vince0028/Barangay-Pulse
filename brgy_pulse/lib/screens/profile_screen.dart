import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../services/supabase_service.dart';
import '../providers/official_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officials = ref.watch(officialProvider);
    final tt = Theme.of(context).textTheme;
    final user = SupabaseService.currentUser;
    final isLoggedIn = user != null;
    final displayName = user?.userMetadata?['full_name'] as String? ?? 'Guest User';
    final displayEmail = user?.email ?? 'Not signed in';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // User card
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: isLoggedIn
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : context.cardFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.border, width: 2),
                    ),
                    child: Icon(
                      isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                      size: 36,
                      color: isLoggedIn ? AppColors.primary : context.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(displayName, style: tt.headlineSmall),
                  const SizedBox(height: 2),
                  Text(displayEmail, style: tt.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Auth buttons
            if (!isLoggedIn) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    await SupabaseService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 20),

            // Officials section
            Text('Barangay Officials', style: tt.headlineSmall),
            const SizedBox(height: 4),
            Text('Tap to view and rate', style: tt.bodyMedium),
            const SizedBox(height: 12),

            ...officials.map((o) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      onTap: () => _showRatingSheet(context, ref, o.id, o.name),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(AppTheme.r),
                              ),
                              child: Icon(Icons.badge_outlined, size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(o.name, style: tt.titleMedium),
                                  Text(o.role, style: tt.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                                    const SizedBox(width: 2),
                                    Text(o.averageRating.toStringAsFixed(1), style: tt.titleMedium),
                                  ],
                                ),
                                Text('${o.missionsCompleted} tasks done', style: tt.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            Text('Settings', style: tt.headlineSmall),
            const SizedBox(height: 12),
            _Tile(icon: Icons.notifications_outlined, label: 'Notifications',
                trailing: Switch(value: true, onChanged: (_) {}, activeColor: AppColors.primary)),
            const SizedBox(height: 8),
            _Tile(icon: Icons.info_outline_rounded, label: 'Version',
                trailing: Text('1.0.0', style: tt.bodyMedium)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showRatingSheet(BuildContext context, WidgetRef ref, String officialId, String name) {
    double rating = 4.0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final tt = Theme.of(ctx).textTheme;
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).bottomSheetTheme.backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Rate $name', style: tt.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setModalState(() => rating = (i + 1).toDouble()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 36, color: AppColors.warning,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(officialProvider.notifier).rateOfficial(officialId, rating);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Rating submitted')),
                        );
                      },
                      child: const Text('Submit Rating'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  const _Tile({required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: context.textSecondary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: tt.titleMedium)),
            trailing,
          ],
        ),
      ),
    );
  }
}
