import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/admin_provider.dart';
import '../models/report_model.dart';

class AdminMapScreen extends ConsumerWidget {
  const AdminMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(filteredReportsProvider);
    final activeFilter = ref.watch(categoryFilterProvider);
    final tt = Theme.of(context).textTheme;

    final markers = reports.map((report) {
      final meta = categoryMeta[report.category]!;
      return Marker(
        point: report.location,
        width: 36,
        height: 36,
        child: Container(
          decoration: BoxDecoration(
            color: meta.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: meta.color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(meta.icon, color: Colors.white, size: 16),
        ),
      );
    }).toList();

    return SafeArea(
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(14.5650, 120.9930),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.brgy_pulse_admin',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AdminColors.background.withValues(alpha: 0.9),
                    AdminColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text('Report Map', style: tt.headlineSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AdminColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.cardBorder),
                    ),
                    child: Text(
                      '${reports.length} pins',
                      style: tt.bodySmall?.copyWith(color: AdminColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category chips at bottom
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MapChip(
                    label: 'All',
                    selected: activeFilter == null,
                    onTap: () => ref.read(categoryFilterProvider.notifier).set(null),
                  ),
                  ...ReportCategory.values.map((cat) {
                    final meta = categoryMeta[cat]!;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _MapChip(
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
        ],
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _MapChip({
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
          color: selected
              ? chipColor.withValues(alpha: 0.85)
              : AdminColors.card.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? chipColor : AdminColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : AdminColors.textMuted),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? Colors.white : AdminColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
