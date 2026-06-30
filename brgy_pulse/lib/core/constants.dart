import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'theme.dart';

// ──────────────────────────────────────────────
// Category visual metadata — Material Icons, no emojis
// ──────────────────────────────────────────────

class CategoryMeta {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const CategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class AppConstants {
  AppConstants._();

  static const String barangayName = 'Barangay 183';
  static const double mapCenterLat = 14.5650;
  static const double mapCenterLng = 120.9930;
  static const double barangayRadiusMeters = 500;

  static const Map<ReportCategory, CategoryMeta> categoryMeta = {
    ReportCategory.trash: CategoryMeta(
      label: 'Uncollected Trash',
      icon: Icons.delete_outline_rounded,
      color: Color(0xFFB8860B),
      bgColor: Color(0x1AB8860B),
    ),
    ReportCategory.parking: CategoryMeta(
      label: 'Illegal Parking',
      icon: Icons.local_parking_rounded,
      color: Color(0xFF4A7FBF),
      bgColor: Color(0x1A4A7FBF),
    ),
    ReportCategory.noise: CategoryMeta(
      label: 'Noise Complaint',
      icon: Icons.volume_up_rounded,
      color: Color(0xFF7E57C2),
      bgColor: Color(0x1A7E57C2),
    ),
    ReportCategory.curfew: CategoryMeta(
      label: 'Curfew Violator',
      icon: Icons.nightlight_round,
      color: Color(0xFF5C6BC0),
      bgColor: Color(0x1A5C6BC0),
    ),
    ReportCategory.flood: CategoryMeta(
      label: 'Flood Report',
      icon: Icons.water_rounded,
      color: Color(0xFF1976D2),
      bgColor: Color(0x1A1976D2),
    ),
    ReportCategory.sos: CategoryMeta(
      label: 'SOS / Need Help',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0x1ADC2626),
    ),
    ReportCategory.safeZone: CategoryMeta(
      label: 'Safe Zone',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF16A34A),
      bgColor: Color(0x1A16A34A),
    ),
  };

  static const List<String> floodSeverity = ['Low', 'Medium', 'High'];

  static const Map<ReportStatus, StatusMeta> statusMeta = {
    ReportStatus.pending: StatusMeta(label: 'Pending', color: Color(0xFFD97706)),
    ReportStatus.inProgress: StatusMeta(label: 'In Progress', color: Color(0xFF2563EB)),
    ReportStatus.resolved: StatusMeta(label: 'Resolved', color: Color(0xFF16A34A)),
  };
}

class StatusMeta {
  final String label;
  final Color color;
  const StatusMeta({required this.label, required this.color});
}
