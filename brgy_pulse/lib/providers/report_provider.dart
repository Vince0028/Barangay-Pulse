import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';

// ──────────────────────────────────────────────
// Report state management (Riverpod 3.x Notifier)
// ──────────────────────────────────────────────

class ReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() => _seedReports;

  void addReport(Report report) {
    state = [report, ...state];
  }

  void updateStatus(String id, ReportStatus newStatus) {
    state = state.map((r) {
      return r.id == id ? r.copyWith(status: newStatus) : r;
    }).toList();
  }

  List<Report> getByCategory(ReportCategory category) {
    return state.where((r) => r.category == category).toList();
  }

  List<Report> getByUser(String userId) {
    return state.where((r) => r.reportedBy == userId).toList();
  }

  // Demo data — realistic reports around Taft Avenue / Manila area
  static final List<Report> _seedReports = [
    Report(
      id: 'rpt_001',
      description: 'Trash bags have been sitting outside the covered court since Monday morning. Starting to smell.',
      category: ReportCategory.trash,
      location: const LatLng(14.5636, 120.9936),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      reportedBy: 'demo_user',
    ),
    Report(
      id: 'rpt_002',
      description: 'SUV blocking the fire lane on Estrada St. No hazard lights, been here over an hour.',
      category: ReportCategory.parking,
      location: const LatLng(14.5648, 120.9948),
      status: ReportStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      reportedBy: 'demo_user',
    ),
    Report(
      id: 'rpt_003',
      description: 'Karaoke at full volume past 11pm again on Leon Guinto St. Third time this week.',
      category: ReportCategory.noise,
      location: const LatLng(14.5672, 120.9910),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
      reportedBy: 'user_042',
    ),
    Report(
      id: 'rpt_004',
      description: 'Group of minors hanging around the sari-sari store past curfew hours.',
      category: ReportCategory.curfew,
      location: const LatLng(14.5610, 120.9955),
      status: ReportStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reportedBy: 'demo_user',
    ),
    Report(
      id: 'rpt_005',
      description: 'Flood water rising along Quirino Ave underpass. About ankle-deep now.',
      category: ReportCategory.flood,
      location: const LatLng(14.5690, 120.9890),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      reportedBy: 'user_078',
      floodSeverity: 'Medium',
    ),
    Report(
      id: 'rpt_006',
      description: 'Family of 5 stranded on second floor, water rising fast. Need boat rescue.',
      category: ReportCategory.sos,
      location: const LatLng(14.5625, 120.9900),
      status: ReportStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      reportedBy: 'user_103',
    ),
    Report(
      id: 'rpt_007',
      description: 'Barangay Hall open as evacuation center. Hot meals available.',
      category: ReportCategory.safeZone,
      location: const LatLng(14.5660, 120.9925),
      status: ReportStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      reportedBy: 'admin_001',
    ),
    Report(
      id: 'rpt_008',
      description: 'Trash overflowing from the community dumpster near the daycare center.',
      category: ReportCategory.trash,
      location: const LatLng(14.5680, 120.9960),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      reportedBy: 'demo_user',
    ),
  ];
}

final reportProvider =
    NotifierProvider<ReportNotifier, List<Report>>(ReportNotifier.new);

// Convenience provider: only the current demo user's reports
final myReportsProvider = Provider<List<Report>>((ref) {
  final all = ref.watch(reportProvider);
  return all.where((r) => r.reportedBy == 'demo_user').toList();
});

// Quick stat providers
final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.pending).length;
});

final inProgressCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.inProgress).length;
});

final resolvedCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.resolved).length;
});
