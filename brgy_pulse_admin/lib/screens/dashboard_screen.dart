import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/report_model.dart';
import '../providers/admin_provider.dart';
import 'report_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReports = ref.watch(adminReportProvider);
    final filteredReports = ref.watch(filteredReportsProvider);
    final activeFilter = ref.watch(categoryFilterProvider);
    final tt = Theme.of(context).textTheme;

    final pending = allReports.where((r) => r.status == ReportStatus.pending).length;
    final inProgress = allReports.where((r) => r.status == ReportStatus.inProgress).length;
    final resolved = allReports.where((r) => r.status == ReportStatus.resolved).length;
    final emergencies = allReports.where((r) =>
        (r.category == ReportCategory.sos || r.category == ReportCategory.flood) &&
        r.status != ReportStatus.resolved).length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Command Center', style: tt.headlineLarge),
                  const SizedBox(height: 2),
                  Text('Barangay 201, Manila', style: tt.bodyMedium),
                ],
              ),
            ),
          ),

          // KPI Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _KpiCard(count: allReports.length, label: 'Total', color: AdminColors.primary),
                  const SizedBox(width: 8),
                  _KpiCard(count: pending, label: 'Pending', color: AdminColors.warning),
                  const SizedBox(width: 8),
                  _KpiCard(count: inProgress, label: 'Active', color: AdminColors.primary),
                  const SizedBox(width: 8),
                  _KpiCard(count: emergencies, label: 'Emergency', color: AdminColors.danger),
                ],
              ),
            ),
          ),

          // Category filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text('Filter by Category', style: tt.titleMedium),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: activeFilter == null,
                    onTap: () => ref.read(categoryFilterProvider.notifier).set(null),
                  ),
                  const SizedBox(width: 6),
                  ...ReportCategory.values.map((cat) {
                    final meta = categoryMeta[cat]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FilterChip(
                        label: meta.label,
                        icon: meta.icon,
                        color: meta.color,
                        selected: activeFilter == cat,
                        onTap: () => ref.read(categoryFilterProvider.notifier).set(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text('Reports', style: tt.headlineSmall),
                  const Spacer(),
                  Text('${filteredReports.length} total',
                      style: tt.bodySmall),
                ],
              ),
            ),
          ),

          // Report list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final report = filteredReports[index];
                final meta = categoryMeta[report.category]!;
                final sMeta = statusMeta[report.status]!;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(reportId: report.id),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: meta.bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(meta.icon, color: meta.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(meta.label, style: tt.titleMedium)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: sMeta.color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          sMeta.label,
                                          style: tt.bodySmall?.copyWith(
                                            color: sMeta.color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(report.description, style: tt.bodyMedium,
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 13, color: AdminColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(report.reportedBy, style: tt.bodySmall),
                                      const Spacer(),
                                      Icon(Icons.access_time, size: 13, color: AdminColors.textMuted),
                                      const SizedBox(width: 4),
                                      Text(_timeAgo(report.timestamp), style: tt.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right_rounded, color: AdminColors.textMuted, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredReports.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _KpiCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text('$count',
                  style: tt.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label, style: tt.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AdminColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.15) : AdminColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? chipColor.withValues(alpha: 0.4) : AdminColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? chipColor : AdminColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? chipColor : AdminColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
