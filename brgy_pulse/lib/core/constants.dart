import 'package:flutter/material.dart';
import '../models/report_model.dart';

// ──────────────────────────────────────────────
// Category visual metadata — icons and colors
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

  static const Map<ReportCategory, CategoryMeta> categoryMeta = {
    ReportCategory.trash: CategoryMeta(
      label: 'Uncollected Trash',
      icon: Icons.delete_outline_rounded,
      color: Color(0xFFCC8B3C),
      bgColor: Color(0x1ACC8B3C),
    ),
    ReportCategory.parking: CategoryMeta(
      label: 'Illegal Parking',
      icon: Icons.local_parking_rounded,
      color: Color(0xFF5B8DEF),
      bgColor: Color(0x1A5B8DEF),
    ),
    ReportCategory.noise: CategoryMeta(
      label: 'Noise Complaint',
      icon: Icons.volume_up_rounded,
      color: Color(0xFF9B59B6),
      bgColor: Color(0x1A9B59B6),
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
      color: Color(0xFF2196F3),
      bgColor: Color(0x1A2196F3),
    ),
    ReportCategory.sos: CategoryMeta(
      label: 'SOS / Need Help',
      icon: Icons.warning_amber_rounded,
      color: Color(0xFFE74C3C),
      bgColor: Color(0x1AE74C3C),
    ),
    ReportCategory.safeZone: CategoryMeta(
      label: 'Safe Zone',
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF27AE60),
      bgColor: Color(0x1A27AE60),
    ),
  };

  // Flood severity levels
  static const List<String> floodSeverity = ['Low', 'Medium', 'High'];

  // Report status display info
  static const Map<ReportStatus, _StatusMeta> statusMeta = {
    ReportStatus.pending: _StatusMeta(label: 'Pending', color: Color(0xFFF5A623)),
    ReportStatus.inProgress: _StatusMeta(label: 'In Progress', color: Color(0xFF4A90D9)),
    ReportStatus.resolved: _StatusMeta(label: 'Resolved', color: Color(0xFF27AE60)),
  };
}

class _StatusMeta {
  final String label;
  final Color color;
  const _StatusMeta({required this.label, required this.color});
}
