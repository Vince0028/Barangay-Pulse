import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/report_model.dart';
import '../providers/admin_provider.dart';

class AdminMapScreen extends ConsumerStatefulWidget {
  const AdminMapScreen({super.key});

  @override
  ConsumerState<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends ConsumerState<AdminMapScreen> {
  final MapController _mapController = MapController();
  bool _locationEnabled = false;
  static const _myLocation = LatLng(14.5315, 121.0022); // Mock actual user location

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(filteredReportsProvider);
    final activeFilter = ref.watch(categoryFilterProvider);
    final tt = Theme.of(context).textTheme;

    final markers = reports.map((report) {
      final meta = categoryMeta[report.category]!;
      return Marker(
        point: report.location,
        width: 32, height: 32,
        child: GestureDetector(
          onTap: () => _showClaimSheet(context, ref, report),
          child: Container(
            decoration: BoxDecoration(
              color: meta.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(meta.icon, color: Colors.white, size: 14),
          ),
        ),
      );
    }).toList();

    if (_locationEnabled) {
      markers.add(
        Marker(
          point: _myLocation,
          width: 24, height: 24,
          child: Container(
            decoration: BoxDecoration(
              color: AdminColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(color: AdminColors.primary.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 4),
              ],
            ),
          ),
        )
      );
    }

    return SafeArea(
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: LatLng(14.5650, 120.9930), initialZoom: 15.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.brgy_pulse_admin',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: context.surface.withValues(alpha: 0.92),
              child: Row(
                children: [
                  Text('Task Map', style: tt.headlineSmall),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.cardFill,
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: context.border),
                    ),
                    child: Text('${reports.length} tasks', style: tt.bodySmall),
                  ),
                ],
              ),
            ),
          ),

          // Location prompt
          if (!_locationEnabled)
            Positioned(
              top: 60, left: 16, right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() => _locationEnabled = true);
                  _mapController.move(_myLocation, 17);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(kRadius),
                    border: Border.all(color: AdminColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AdminColors.primary),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Enable location to view your position',
                          style: tt.bodySmall?.copyWith(color: AdminColors.primary))),
                      Text('Enable', style: tt.bodySmall?.copyWith(
                          color: AdminColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),

          // Category chips
          Positioned(
            bottom: 16, left: 0, right: 0,
            child: SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MapChip(label: 'All', selected: activeFilter == null,
                      onTap: () => ref.read(categoryFilterProvider.notifier).set(null)),
                  ...ReportCategory.values.map((cat) {
                    final meta = categoryMeta[cat]!;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _MapChip(
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
        ],
      ),
    );
  }

  void _showClaimSheet(BuildContext context, WidgetRef ref, Report report) {
    final meta = categoryMeta[report.category]!;
    final sMeta = statusMeta[report.status]!;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: meta.bgColor,
                      borderRadius: BorderRadius.circular(kRadius),
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meta.label, style: tt.headlineSmall),
                        Text('Reported by ${report.reportedBy}', style: tt.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sMeta.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(sMeta.label,
                        style: tt.bodySmall?.copyWith(color: sMeta.color, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(report.description, style: tt.bodyLarge),
              const SizedBox(height: 16),

              if (report.status == ReportStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final officer = ref.read(officerProfileProvider);
                      ref.read(adminReportProvider.notifier).claimReport(report.id, officer.name);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task claimed')),
                      );
                    },
                    icon: const Icon(Icons.assignment_ind_rounded, size: 18),
                    label: const Text('Claim This Task'),
                  ),
                ),
              if (report.status == ReportStatus.inProgress)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(adminReportProvider.notifier).resolveReport(report.id);
                      ref.read(officerProfileProvider.notifier).completeTaskLocally(report.id, report.category);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Task resolved! +${categoryPoints[report.category] ?? 10} points')),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Mark Resolved'),
                    style: ElevatedButton.styleFrom(backgroundColor: AdminColors.success),
                  ),
                ),
              if (report.status == ReportStatus.resolved)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(kRadius),
                    border: Border.all(color: AdminColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 16, color: AdminColors.success),
                      const SizedBox(width: 8),
                      Text('Already resolved', style: tt.bodyMedium?.copyWith(color: AdminColors.success)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _MapChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;
  const _MapChip({required this.label, this.icon, this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.85) : context.cardFill.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(color: selected ? c : context.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: selected ? Colors.white : context.textMuted),
              const SizedBox(width: 3),
            ],
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: selected ? Colors.white : context.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}
