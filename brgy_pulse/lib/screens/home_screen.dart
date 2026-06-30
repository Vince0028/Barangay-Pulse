import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/report_provider.dart';
import '../providers/announcement_provider.dart';
import '../models/report_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportProvider);
    final announcements = ref.watch(announcementProvider);
    final pending = ref.watch(pendingCountProvider);
    final inProgress = ref.watch(inProgressCountProvider);
    final resolved = ref.watch(resolvedCountProvider);
    final tt = Theme.of(context).textTheme;

    final hasEmergency = reports.any((r) =>
        (r.category == ReportCategory.flood ||
            r.category == ReportCategory.sos) &&
        r.status != ReportStatus.resolved);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', width: 56, height: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: tt.bodyMedium),
                        const SizedBox(height: 2),
                        Text(AppConstants.barangayName, style: tt.headlineLarge),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      ref.read(reportProvider.notifier).refresh();
                      ref.read(announcementProvider.notifier).refresh();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Emergency banner
          if (hasEmergency)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.r),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Emergency Reports',
                              style: tt.titleMedium?.copyWith(color: AppColors.danger)),
                          const SizedBox(height: 2),
                          Text('Flood and SOS reports in your area.',
                              style: tt.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _StatCard(label: 'Pending', count: pending, color: AppColors.warning),
                  const SizedBox(width: 8),
                  _StatCard(label: 'In Progress', count: inProgress, color: AppColors.primary),
                  const SizedBox(width: 8),
                  _StatCard(label: 'Resolved', count: resolved, color: AppColors.success),
                ],
              ),
            ),
          ),

          // Latest announcement preview
          if (announcements.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest Announcement', style: tt.headlineSmall),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(announcements.first.title, style: tt.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              announcements.first.body,
                              style: tt.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person_outline, size: 13, color: context.textMuted),
                                const SizedBox(width: 4),
                                Text(announcements.first.postedBy, style: tt.bodySmall),
                                const Spacer(),
                                Text(_timeAgo(announcements.first.timestamp), style: tt.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Recent reports header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Recent Reports', style: tt.headlineSmall),
            ),
          ),

          // Report cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) {
                final report = reports[index];
                final meta = AppConstants.categoryMeta[report.category]!;
                final statusMeta = AppConstants.statusMeta[report.status]!;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: meta.bgColor,
                              borderRadius: BorderRadius.circular(AppTheme.r),
                            ),
                            child: Icon(meta.icon, color: meta.color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(meta.label, style: tt.titleMedium),
                                const SizedBox(height: 2),
                                Text(report.description, style: tt.bodyMedium,
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 12, color: context.textMuted),
                                    const SizedBox(width: 3),
                                    Text(_timeAgo(report.timestamp), style: tt.bodySmall),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusMeta.color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(statusMeta.label,
                                          style: tt.bodySmall?.copyWith(
                                            color: statusMeta.color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: reports.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text('$count', style: tt.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: tt.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
