import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../services/supabase_service.dart';
import '../providers/admin_provider.dart';
import 'auth/admin_login_screen.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final officer = ref.watch(officerProfileProvider);
    final allReports = ref.watch(adminReportProvider);
    final resolved = allReports.where((r) => officer.completedReportIds.contains(r.id)).toList();
    final tt = Theme.of(context).textTheme;
    final user = SupabaseService.currentUser;
    final isLoggedIn = user != null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: context.border, width: 2),
                    ),
                    child: Icon(Icons.badge_rounded, size: 36, color: AdminColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(isLoggedIn ? (user.userMetadata?['full_name'] ?? officer.name) : officer.name,
                      style: tt.headlineSmall),
                  const SizedBox(height: 2),
                  Text(officer.role, style: tt.bodyMedium),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 2),
                    Text(user.email ?? '', style: tt.bodySmall),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 16, color: AdminColors.warning),
                      const SizedBox(width: 2),
                      Text('${officer.averageRating.toStringAsFixed(1)} (${officer.ratingsCount} ratings)',
                          style: tt.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                _StatCard(label: 'Points', value: '${officer.points}', color: AdminColors.primary),
                const SizedBox(width: 8),
                _StatCard(label: 'Missions', value: '${officer.missionsCompleted}', color: AdminColors.success),
                const SizedBox(width: 8),
                _StatCard(label: 'Rating', value: officer.averageRating.toStringAsFixed(1), color: AdminColors.warning),
              ],
            ),
            const SizedBox(height: 24),

            Text('Top Officers', style: tt.headlineSmall),
            const SizedBox(height: 8),
            // TODO: Fetch top officers from database
            Text('No officers ranked yet.', style: tt.bodySmall?.copyWith(color: context.textMuted)),

            const SizedBox(height: 24),

            Row(
              children: [
                Text('Completed Tasks', style: tt.headlineSmall),
                const Spacer(),
                Text('${resolved.length}', style: tt.bodySmall),
              ],
            ),
            const SizedBox(height: 8),

            if (resolved.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: Text('Complete tasks from the map to earn points.', style: tt.bodyMedium)),
                ),
              )
            else
              ...resolved.map((r) {
                final meta = categoryMeta[r.category]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: meta.bgColor, borderRadius: BorderRadius.circular(kRadius)),
                            child: Icon(meta.icon, color: meta.color, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meta.label, style: tt.titleMedium),
                                Text(r.description, style: tt.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('+${categoryPoints[r.category] ?? 10} pts',
                                style: tt.bodySmall?.copyWith(color: AdminColors.success, fontWeight: FontWeight.w600, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            Text('Account', style: tt.headlineSmall),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: isLoggedIn
                  ? OutlinedButton(
                      onPressed: () async {
                        await SupabaseService.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Sign Out'),
                    )
                  : OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                      },
                      child: const Text('Sign In'),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Text(value, style: tt.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: tt.bodySmall),
          ]),
        ),
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int pts;
  const _LeaderRow({required this.rank, required this.name, required this.pts});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final medal = rank == 1 ? Icons.emoji_events_rounded : Icons.military_tech_rounded;
    final color = rank == 1 ? AdminColors.warning : rank == 2 ? const Color(0xFFA0A0A0) : const Color(0xFFCD7F32);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            Icon(medal, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(name, style: tt.titleMedium)),
            Text('$pts pts', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
