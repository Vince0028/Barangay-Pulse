import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../core/constants.dart';
import '../core/theme.dart';
import '../providers/report_provider.dart';
import '../widgets/report_bottom_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _cleanMode = false; // toggles simplified tiles

  static const _center = LatLng(
    AppConstants.mapCenterLat,
    AppConstants.mapCenterLng,
  );

  // Generate circle points for barangay boundary
  List<LatLng> _buildCircle(LatLng center, double radiusMeters, int points) {
    final result = <LatLng>[];
    for (int i = 0; i < points; i++) {
      final angle = (2 * pi * i) / points;
      final dLat = (radiusMeters / 111320) * cos(angle);
      final dLng = (radiusMeters / (111320 * cos(center.latitude * pi / 180))) * sin(angle);
      result.add(LatLng(center.latitude + dLat, center.longitude + dLng));
    }
    return result;
  }

  void _showReportBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReportBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportProvider);
    final tt = Theme.of(context).textTheme;

    final boundaryPoints = _buildCircle(_center, AppConstants.barangayRadiusMeters, 64);

    final markers = reports.map((report) {
      final meta = AppConstants.categoryMeta[report.category]!;
      return Marker(
        point: report.location,
        width: 32,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: meta.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Icon(meta.icon, color: Colors.white, size: 14),
        ),
      );
    }).toList();

    final tileUrl = _cleanMode
        ? 'https://basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return SafeArea(
      child: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15.5,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.example.brgy_pulse',
              ),
              // Barangay boundary
              PolygonLayer(
                polygons: <Polygon<Object>>[
                  Polygon(
                    points: boundaryPoints,
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderColor: AppColors.primary.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              // Report markers
              MarkerLayer(markers: markers),
            ],
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: context.surface.withValues(alpha: 0.92),
              ),
              child: Row(
                children: [
                  Text(AppConstants.barangayName, style: tt.headlineSmall),
                  const Spacer(),
                  // POI toggle
                  GestureDetector(
                    onTap: () => setState(() => _cleanMode = !_cleanMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: _cleanMode
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : context.cardFill,
                        borderRadius: BorderRadius.circular(AppTheme.r),
                        border: Border.all(
                          color: _cleanMode
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : context.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _cleanMode ? Icons.layers_clear_rounded : Icons.layers_rounded,
                            size: 14,
                            color: _cleanMode ? AppColors.primary : context.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _cleanMode ? 'Focus' : 'Full',
                            style: tt.bodySmall?.copyWith(
                              color: _cleanMode ? AppColors.primary : context.textSecondary,
                              fontWeight: _cleanMode ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Active count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: context.cardFill,
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      border: Border.all(color: context.border),
                    ),
                    child: Text('${reports.length} reports', style: tt.bodySmall),
                  ),
                ],
              ),
            ),
          ),

          // Location prompt banner
          Positioned(
            top: 44,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.r),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Enable location for accurate reporting',
                        style: tt.bodySmall?.copyWith(color: AppColors.primary)),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: geolocator permission request
                    },
                    child: Text('Enable',
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
          ),

          // FAB
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _showReportBottomSheet,
              icon: const Icon(Icons.add_location_alt_rounded, size: 18),
              label: const Text('Report'),
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r)),
            ),
          ),
        ],
      ),
    );
  }
}
