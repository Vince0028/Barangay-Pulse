import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/announcement_provider.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcements = ref.watch(announcementProvider);
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Row(
              children: [
                Expanded(child: Text('Announcements', style: tt.headlineLarge)),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.read(announcementProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text('Posts from your barangay officials', style: tt.bodyMedium),
          ),

          Expanded(
            child: announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.campaign_outlined, size: 40, color: context.textMuted),
                        const SizedBox(height: 10),
                        Text('No announcements yet', style: tt.titleMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, index) {
                      final a = announcements[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Posted by + time
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(AppTheme.r),
                                    ),
                                    child: Icon(Icons.person_rounded,
                                        size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.postedBy, style: tt.titleMedium),
                                        Text(a.posterRole, style: tt.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(_timeAgo(a.timestamp), style: tt.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Title
                              Text(a.title,
                                  style: tt.titleLarge),
                              const SizedBox(height: 6),

                              // Body
                              Text(a.body, style: tt.bodyMedium),
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
