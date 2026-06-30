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
  bool _cleanMode = false;
  bool _pinPlacementMode = false;
  LatLng _pinLocation = const LatLng(AppConstants.mapCenterLat, AppConstants.mapCenterLng);

  // Coordinate input controllers
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  bool _showCoordinateInput = false;

  static const _center = LatLng(AppConstants.mapCenterLat, AppConstants.mapCenterLng);

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

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

  void _enterPinMode() {
    setState(() {
      _pinPlacementMode = true;
      _pinLocation = _mapController.camera.center;
      _showCoordinateInput = false;
    });
  }

  void _confirmLocation() {
    setState(() => _pinPlacementMode = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportBottomSheet(location: _pinLocation),
    );
  }

  void _applyCoordinates() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setState(() {
        _pinLocation = LatLng(lat, lng);
        _showCoordinateInput = false;
      });
      _mapController.move(_pinLocation, _mapController.camera.zoom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coordinates')),
      );
    }
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
        width: 32, height: 32,
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

    // Add draggable pin in placement mode
    if (_pinPlacementMode) {
      markers.add(Marker(
        point: _pinLocation,
        width: 40, height: 50,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Color(0xFFDC2626), size: 36),
            SizedBox(height: 2),
            // Shadow dot
            DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0x40000000),
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 6, height: 6),
            ),
          ],
        ),
      ));
    }

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
              onTap: _pinPlacementMode
                  ? (tapPos, latlng) {
                      setState(() => _pinLocation = latlng);
                    }
                  : null,
              onLongPress: _pinPlacementMode
                  ? (tapPos, latlng) {
                      setState(() => _pinLocation = latlng);
                    }
                  : null,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.example.brgy_pulse',
              ),
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
              MarkerLayer(markers: markers),
            ],
          ),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: context.surface.withValues(alpha: 0.92),
              child: Row(
                children: [
                  Text(
                    _pinPlacementMode ? 'Tap to place pin' : AppConstants.barangayName,
                    style: tt.headlineSmall,
                  ),
                  const Spacer(),
                  if (!_pinPlacementMode) ...[
                    GestureDetector(
                      onTap: () => setState(() => _cleanMode = !_cleanMode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _cleanMode ? AppColors.primary.withValues(alpha: 0.1) : context.cardFill,
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(color: _cleanMode ? AppColors.primary.withValues(alpha: 0.3) : context.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_cleanMode ? Icons.layers_clear_rounded : Icons.layers_rounded,
                                size: 14, color: _cleanMode ? AppColors.primary : context.textMuted),
                            const SizedBox(width: 4),
                            Text(_cleanMode ? 'Focus' : 'Full',
                                style: tt.bodySmall?.copyWith(
                                  color: _cleanMode ? AppColors.primary : context.textSecondary,
                                  fontWeight: _cleanMode ? FontWeight.w600 : FontWeight.w400,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.cardFill,
                        borderRadius: BorderRadius.circular(AppTheme.r),
                        border: Border.all(color: context.border),
                      ),
                      child: Text('${reports.length} reports', style: tt.bodySmall),
                    ),
                  ] else ...[
                    GestureDetector(
                      onTap: () => setState(() => _pinPlacementMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: context.cardFill,
                          borderRadius: BorderRadius.circular(AppTheme.r),
                          border: Border.all(color: context.border),
                        ),
                        child: Text('Cancel', style: tt.bodySmall?.copyWith(color: AppColors.danger)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Location prompt (only when not in pin mode)
          if (!_pinPlacementMode)
            Positioned(
              top: 44, left: 16, right: 16,
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
                    Expanded(child: Text('Enable location for accurate reporting',
                        style: tt.bodySmall?.copyWith(color: AppColors.primary))),
                    Text('Enable', style: tt.bodySmall?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          // Pin placement info bar at bottom
          if (_pinPlacementMode)
            Positioned(
              bottom: 80, left: 16, right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coordinate display / input toggle
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      border: Border.all(color: context.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_pinLocation.latitude.toStringAsFixed(6)}, ${_pinLocation.longitude.toStringAsFixed(6)}',
                                style: tt.titleMedium,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _showCoordinateInput = !_showCoordinateInput),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _showCoordinateInput
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : context.cardFill,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: context.border),
                                ),
                                child: Text('Input', style: tt.bodySmall?.copyWith(
                                    color: _showCoordinateInput ? AppColors.primary : context.textSecondary)),
                              ),
                            ),
                          ],
                        ),
                        if (_showCoordinateInput) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _latController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  style: tt.bodyMedium,
                                  decoration: InputDecoration(
                                    labelText: 'Latitude',
                                    hintText: '${_pinLocation.latitude.toStringAsFixed(4)}',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _lngController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                  style: tt.bodyMedium,
                                  decoration: InputDecoration(
                                    labelText: 'Longitude',
                                    hintText: '${_pinLocation.longitude.toStringAsFixed(4)}',
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: _applyCoordinates,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    textStyle: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  child: const Text('Go'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // FAB
          Positioned(
            bottom: 16, right: 16,
            child: _pinPlacementMode
                ? FloatingActionButton.extended(
                    onPressed: _confirmLocation,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Confirm Location'),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.r)),
                  )
                : FloatingActionButton.extended(
                    onPressed: _enterPinMode,
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
