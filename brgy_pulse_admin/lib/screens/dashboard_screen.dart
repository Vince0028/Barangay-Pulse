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
    final emergencies = allReports.where((r) =>
        (r.category == ReportCategory.sos || r.category == ReportCategory.flood) &&
        r.status != ReportStatus.resolved).length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', width: 56, height: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Command Center', style: tt.headlineLarge),
                            const SizedBox(height: 2),
                            Text('Barangay 183', style: tt.bodyMedium),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          ref.read(adminReportProvider.notifier).refresh();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // KPI row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _Kpi(count: allReports.length, label: 'Total', color: AdminColors.primary),
                  const SizedBox(width: 8),
                  _Kpi(count: pending, label: 'Pending', color: AdminColors.warning),
                  const SizedBox(width: 8),
                  _Kpi(count: inProgress, label: 'Active', color: AdminColors.primary),
                  const SizedBox(width: 8),
                  _Kpi(count: emergencies, label: 'Emergency', color: AdminColors.danger),
                ],
              ),
            ),
          ),

          // Category filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('Filter', style: tt.labelLarge),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _Chip(label: 'All', selected: activeFilter == null,
                      onTap: () => ref.read(categoryFilterProvider.notifier).set(null)),
                  const SizedBox(width: 6),
                  ...ReportCategory.values.map((cat) {
                    final meta = categoryMeta[cat]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _Chip(
                        label: meta.label, icon: meta.icon, color: meta.color,
                        selected: activeFilter == cat,
                        onTap: () => ref.read(categoryFilterProvider.notifier).set(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Reports header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  Text('Reports', style: tt.headlineSmall),
                  const Spacer(),
                  Text('${filteredReports.length} total', style: tt.bodySmall),
                ],
              ),
            ),
          ),

          // Report list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final r = filteredReports[index];
                final meta = categoryMeta[r.category]!;
                final sMeta = statusMeta[r.status]!;

                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(reportId: r.id),
                  )),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: meta.bgColor,
                                borderRadius: BorderRadius.circular(kRadius),
                              ),
                              child: Icon(meta.icon, color: meta.color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(meta.label, style: tt.titleMedium)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: sMeta.color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(sMeta.label,
                                            style: tt.bodySmall?.copyWith(
                                              color: sMeta.color,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            )),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(r.description, style: tt.bodyMedium,
                                      maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 12, color: context.textMuted),
                                      const SizedBox(width: 3),
                                      Text(r.reportedBy, style: tt.bodySmall),
                                      const Spacer(),
                                      Text(_timeAgo(r.timestamp), style: tt.bodySmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right_rounded, color: context.textMuted, size: 18),
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
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _Kpi({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
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

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, this.icon, this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.1) : context.cardFill,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: selected ? c.withValues(alpha: 0.3) : context.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: selected ? c : context.textMuted),
              const SizedBox(width: 3),
            ],
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? c : context.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}
