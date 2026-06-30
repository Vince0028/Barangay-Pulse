import 'package:flutter/material.dart';
import '../models/report_model.dart';

// ──────────────────────────────────────────────
// Colors — darker, more serious palette for admin
// ──────────────────────────────────────────────

class AdminColors {
  AdminColors._();

  static const Color background = Color(0xFF0A1219);
  static const Color surface = Color(0xFF141E28);
  static const Color card = Color(0xFF1C2A36);
  static const Color cardBorder = Color(0xFF273644);

  static const Color primary = Color(0xFF3B82F6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static const Color textPrimary = Color(0xFFE8ECF1);
  static const Color textSecondary = Color(0xFF7E8FA0);
  static const Color textMuted = Color(0xFF4B5D6E);

  static const Color divider = Color(0xFF1F3040);
}

// ──────────────────────────────────────────────
// Category metadata (same as civilian, copied here)
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

const Map<ReportCategory, CategoryMeta> categoryMeta = {
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

const Map<ReportStatus, StatusMeta> statusMeta = {
  ReportStatus.pending: StatusMeta(label: 'Pending', color: Color(0xFFF5A623)),
  ReportStatus.inProgress: StatusMeta(label: 'In Progress', color: Color(0xFF4A90D9)),
  ReportStatus.resolved: StatusMeta(label: 'Resolved', color: Color(0xFF27AE60)),
};

class StatusMeta {
  final String label;
  final Color color;
  const StatusMeta({required this.label, required this.color});
}
