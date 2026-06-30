import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/report_provider.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myReports = ref.watch(myReportsProvider);
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text('My Reports', style: tt.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              '${myReports.length} report${myReports.length == 1 ? '' : 's'} submitted',
              style: tt.bodyMedium,
            ),
          ),
          Expanded(
            child: myReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.assignment_outlined, size: 40, color: context.textMuted),
                        const SizedBox(height: 10),
                        Text('No reports yet', style: tt.titleMedium),
                        const SizedBox(height: 4),
                        Text('Use the map to report issues.', style: tt.bodyMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: myReports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, index) {
                      final report = myReports[index];
                      final meta = AppConstants.categoryMeta[report.category]!;
                      final statusMeta = AppConstants.statusMeta[report.status]!;

                      return Card(
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
                                    Row(
                                      children: [
                                        Expanded(child: Text(meta.label, style: tt.titleMedium)),
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
                                    const SizedBox(height: 3),
                                    Text(report.description, style: tt.bodyMedium,
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 12, color: context.textMuted),
                                        const SizedBox(width: 3),
                                        Text(_timeAgo(report.timestamp), style: tt.bodySmall),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
