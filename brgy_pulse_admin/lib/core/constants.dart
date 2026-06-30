import 'package:flutter/material.dart';
import '../models/report_model.dart';

// ──────────────────────────────────────────────
// Accent colors (shared)
// ──────────────────────────────────────────────

class AdminColors {
  AdminColors._();
  static const Color primary = Color(0xFF2563EB);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
}

// ──────────────────────────────────────────────
// Context extension for mode-dependent colors
// ──────────────────────────────────────────────

extension AdminThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? const Color(0xFF121214) : const Color(0xFFF5F5F5);
  Color get surface => isDark ? const Color(0xFF1C1C1F) : Colors.white;
  Color get cardFill => isDark ? const Color(0xFF242428) : Colors.white;
  Color get border => isDark ? const Color(0xFF333338) : const Color(0xFFE2E4E9);
  Color get textPrimary => isDark ? const Color(0xFFE4E4E7) : const Color(0xFF1A1A2E);
  Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
  Color get textMuted => isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF);
}

// ──────────────────────────────────────────────
// Category & Status metadata
// ──────────────────────────────────────────────

class CategoryMeta {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const CategoryMeta({required this.label, required this.icon, required this.color, required this.bgColor});
}

const double kRadius = 6.0;

const Map<ReportCategory, CategoryMeta> categoryMeta = {
  ReportCategory.trash: CategoryMeta(label: 'Uncollected Trash', icon: Icons.delete_outline_rounded, color: Color(0xFFB8860B), bgColor: Color(0x1AB8860B)),
  ReportCategory.parking: CategoryMeta(label: 'Illegal Parking', icon: Icons.local_parking_rounded, color: Color(0xFF4A7FBF), bgColor: Color(0x1A4A7FBF)),
  ReportCategory.noise: CategoryMeta(label: 'Noise Complaint', icon: Icons.volume_up_rounded, color: Color(0xFF7E57C2), bgColor: Color(0x1A7E57C2)),
  ReportCategory.curfew: CategoryMeta(label: 'Curfew Violator', icon: Icons.nightlight_round, color: Color(0xFF5C6BC0), bgColor: Color(0x1A5C6BC0)),
  ReportCategory.flood: CategoryMeta(label: 'Flood Report', icon: Icons.water_rounded, color: Color(0xFF1976D2), bgColor: Color(0x1A1976D2)),
  ReportCategory.sos: CategoryMeta(label: 'SOS / Need Help', icon: Icons.warning_amber_rounded, color: Color(0xFFDC2626), bgColor: Color(0x1ADC2626)),
  ReportCategory.safeZone: CategoryMeta(label: 'Safe Zone', icon: Icons.health_and_safety_rounded, color: Color(0xFF16A34A), bgColor: Color(0x1A16A34A)),
};

const Map<ReportStatus, StatusMeta> statusMeta = {
  ReportStatus.pending: StatusMeta(label: 'Pending', color: Color(0xFFD97706)),
  ReportStatus.inProgress: StatusMeta(label: 'In Progress', color: Color(0xFF2563EB)),
  ReportStatus.resolved: StatusMeta(label: 'Resolved', color: Color(0xFF16A34A)),
};

class StatusMeta {
  final String label;
  final Color color;
  const StatusMeta({required this.label, required this.color});
}

// Points per category
const Map<ReportCategory, int> categoryPoints = {
  ReportCategory.trash: 10,
  ReportCategory.parking: 10,
  ReportCategory.noise: 15,
  ReportCategory.curfew: 20,
  ReportCategory.flood: 25,
  ReportCategory.sos: 30,
  ReportCategory.safeZone: 5,
};
