import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';

// ──────────────────────────────────────────────
// Admin report state (Riverpod 3.x Notifier)
// ──────────────────────────────────────────────

class AdminReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() => _seedReports;

  void updateStatus(String id, ReportStatus newStatus) {
    state = state.map((r) {
      return r.id == id ? r.copyWith(status: newStatus) : r;
    }).toList();
  }

  void addNotes(String id, String notes) {
    state = state.map((r) {
      return r.id == id ? r.copyWith(adminNotes: notes) : r;
    }).toList();
  }

  List<Report> filterByCategory(ReportCategory? category) {
    if (category == null) return state;
    return state.where((r) => r.category == category).toList();
  }

  static final List<Report> _seedReports = [
    Report(
      id: 'rpt_001',
      description: 'Trash bags have been sitting outside the covered court since Monday morning. Starting to smell.',
      category: ReportCategory.trash,
      location: const LatLng(14.5636, 120.9936),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      reportedBy: 'Juan D. (Zone 3)',
    ),
    Report(
      id: 'rpt_002',
      description: 'SUV blocking the fire lane on Estrada St. No hazard lights, been here over an hour.',
      category: ReportCategory.parking,
      location: const LatLng(14.5648, 120.9948),
      status: ReportStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      reportedBy: 'Maria C. (Zone 1)',
    ),
    Report(
      id: 'rpt_003',
      description: 'Karaoke at full volume past 11pm again on Leon Guinto St. Third time this week.',
      category: ReportCategory.noise,
      location: const LatLng(14.5672, 120.9910),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
      reportedBy: 'Pedro R. (Zone 2)',
    ),
    Report(
      id: 'rpt_004',
      description: 'Group of minors hanging around the sari-sari store past curfew hours.',
      category: ReportCategory.curfew,
      location: const LatLng(14.5610, 120.9955),
      status: ReportStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reportedBy: 'Ana L. (Zone 4)',
      adminNotes: 'Tanod dispatched. Parents contacted.',
    ),
    Report(
      id: 'rpt_005',
      description: 'Flood water rising along Quirino Ave underpass. About ankle-deep now.',
      category: ReportCategory.flood,
      location: const LatLng(14.5690, 120.9890),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      reportedBy: 'Roberto M. (Zone 5)',
      floodSeverity: 'Medium',
    ),
    Report(
      id: 'rpt_006',
      description: 'Family of 5 stranded on second floor, water rising fast. Need boat rescue.',
      category: ReportCategory.sos,
      location: const LatLng(14.5625, 120.9900),
      status: ReportStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      reportedBy: 'Gloria S. (Zone 5)',
    ),
    Report(
      id: 'rpt_007',
      description: 'Barangay Hall open as evacuation center. Hot meals available.',
      category: ReportCategory.safeZone,
      location: const LatLng(14.5660, 120.9925),
      status: ReportStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      reportedBy: 'Admin Office',
    ),
    Report(
      id: 'rpt_008',
      description: 'Trash overflowing from the community dumpster near the daycare center.',
      category: ReportCategory.trash,
      location: const LatLng(14.5680, 120.9960),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      reportedBy: 'Lisa T. (Zone 2)',
    ),
    Report(
      id: 'rpt_009',
      description: 'Motorcycle parked on the sidewalk blocking pedestrian access near the school.',
      category: ReportCategory.parking,
      location: const LatLng(14.5645, 120.9915),
      status: ReportStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      reportedBy: 'Carlos B. (Zone 1)',
    ),
    Report(
      id: 'rpt_010',
      description: 'Construction noise from building site starting before 6am, violating noise ordinance.',
      category: ReportCategory.noise,
      location: const LatLng(14.5665, 120.9945),
      status: ReportStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      reportedBy: 'Elena V. (Zone 3)',
    ),
  ];
}

final adminReportProvider =
    NotifierProvider<AdminReportNotifier, List<Report>>(AdminReportNotifier.new);

// Category filter state
class CategoryFilterNotifier extends Notifier<ReportCategory?> {
  @override
  ReportCategory? build() => null;

  void set(ReportCategory? category) {
    state = category;
  }
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, ReportCategory?>(CategoryFilterNotifier.new);

// Filtered reports
final filteredReportsProvider = Provider<List<Report>>((ref) {
  final reports = ref.watch(adminReportProvider);
  final filter = ref.watch(categoryFilterProvider);
  if (filter == null) return reports;
  return reports.where((r) => r.category == filter).toList();
});

// Broadcast history
class Broadcast {
  final String message;
  final String severity;
  final String zone;
  final DateTime timestamp;

  Broadcast({
    required this.message,
    required this.severity,
    required this.zone,
    required this.timestamp,
  });
}

class BroadcastNotifier extends Notifier<List<Broadcast>> {
  @override
  List<Broadcast> build() => [
    Broadcast(
      message: 'Heavy rainfall expected tonight. Secure loose items outdoors.',
      severity: 'Advisory',
      zone: 'All Zones',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  void addBroadcast(Broadcast broadcast) {
    state = [broadcast, ...state];
  }
}

final broadcastProvider =
    NotifierProvider<BroadcastNotifier, List<Broadcast>>(BroadcastNotifier.new);
