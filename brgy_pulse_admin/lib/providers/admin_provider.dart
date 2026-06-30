import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../models/announcement_model.dart';
import '../models/official_model.dart';
import '../core/constants.dart';
import '../repositories/admin_report_repository.dart';
import '../repositories/admin_announcement_repo.dart';
import '../services/supabase_service.dart';

// ──────────────────────────────────────────────
// Admin report state
// ──────────────────────────────────────────────

class AdminReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() => [];

  Future<void> refresh() async {
    state = await AdminReportRepository.fetchAll();
  }

  Future<void> updateStatus(String id, ReportStatus newStatus) async {
    await AdminReportRepository.updateStatus(id, newStatus);
    await refresh();
  }

  Future<void> addNotes(String id, String notes) async {
    final report = state.firstWhere((r) => r.id == id);
    await AdminReportRepository.updateStatus(id, report.status, notes: notes);
    await refresh();
  }

  Future<void> claimReport(String id, String officerName) async {
    await AdminReportRepository.claimReport(id);
    await refresh();
  }

  Future<void> resolveReport(String id) async {
    await AdminReportRepository.resolveReport(id);
    await refresh();
  }

  Future<void> unclaimReport(String id) async {
    await AdminReportRepository.unclaimReport(id);
    await refresh();
  }
}

final adminReportProvider =
    NotifierProvider<AdminReportNotifier, List<Report>>(AdminReportNotifier.new);

// Category filter
class CategoryFilterNotifier extends Notifier<ReportCategory?> {
  @override
  ReportCategory? build() => null;
  void set(ReportCategory? category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, ReportCategory?>(CategoryFilterNotifier.new);

final filteredReportsProvider = Provider<List<Report>>((ref) {
  final reports = ref.watch(adminReportProvider);
  final filter = ref.watch(categoryFilterProvider);
  if (filter == null) return reports;
  return reports.where((r) => r.category == filter).toList();
});

// ──────────────────────────────────────────────
// Broadcasts
// ──────────────────────────────────────────────

class Broadcast {
  final String id;
  final String message;
  final String severity;
  final String zone;
  final DateTime timestamp;
  Broadcast({required this.id, required this.message, required this.severity, required this.zone, required this.timestamp});
}

class BroadcastNotifier extends Notifier<List<Broadcast>> {
  @override
  List<Broadcast> build() => [];

  Future<void> refresh() async {
    if (!SupabaseService.isConfigured) return;
    final res = await SupabaseService.client
        .from('broadcasts')
        .select()
        .order('created_at', ascending: false);
        
    state = (res as List).map((e) => Broadcast(
      id: e['id'],
      message: e['message'],
      severity: e['severity'],
      zone: e['zone'],
      timestamp: DateTime.parse(e['created_at']),
    )).toList();
  }

  Future<void> addBroadcast(String message, String severity, String zone) async {
    if (!SupabaseService.isConfigured) return;
    await SupabaseService.client.from('broadcasts').insert({
      'message': message,
      'severity': severity,
      'zone': zone,
      'posted_by': SupabaseService.currentUser?.id,
    });
    await refresh();
  }
}

final broadcastProvider =
    NotifierProvider<BroadcastNotifier, List<Broadcast>>(BroadcastNotifier.new);

// ──────────────────────────────────────────────
// Announcements (admin side — can create/edit)
// ──────────────────────────────────────────────

class AdminAnnouncementNotifier extends Notifier<List<Announcement>> {
  @override
  List<Announcement> build() => [];

  Future<void> refresh() async {
    state = await AdminAnnouncementRepository.fetchAll();
  }

  Future<void> addAnnouncement(String title, String body) async {
    await AdminAnnouncementRepository.create(title, body);
    await refresh();
  }

  Future<void> deleteAnnouncement(String id) async {
    await AdminAnnouncementRepository.delete(id);
    await refresh();
  }
}

final adminAnnouncementProvider =
    NotifierProvider<AdminAnnouncementNotifier, List<Announcement>>(AdminAnnouncementNotifier.new);

// ──────────────────────────────────────────────
// Current officer profile (gamification)
// ──────────────────────────────────────────────

class OfficerProfileNotifier extends Notifier<Official> {
  @override
  Official build() => Official(
    id: SupabaseService.currentUser?.id ?? 'off_current',
    name: SupabaseService.currentUser?.userMetadata?['full_name'] ?? 'Demo Officer',
    role: 'Barangay Official',
    points: 0,
    missionsCompleted: 0,
    averageRating: 0.0,
    ratingsCount: 0,
    completedReportIds: [],
  );

  Future<void> refresh() async {
    if (!SupabaseService.isConfigured) return;
    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return;
    
    // Fetch profile and points from official_ratings view
    final res = await SupabaseService.client.from('official_ratings').select().eq('id', uid).maybeSingle();
    if (res != null) {
      state = Official(
        id: res['id'],
        name: res['full_name'] ?? state.name,
        role: res['role_title'] ?? state.role,
        points: res['points'] ?? 0,
        missionsCompleted: res['missions_completed'] ?? 0,
        averageRating: (res['average_rating'] as num?)?.toDouble() ?? 0.0,
        ratingsCount: res['ratings_count'] ?? 0,
        completedReportIds: state.completedReportIds,
      );
    } else {
      // Fallback: just fetch their profile if they aren't in the officials table yet
      final profileRes = await SupabaseService.client.from('profiles').select().eq('id', uid).maybeSingle();
      if (profileRes != null) {
        state = state.copyWith(
          name: profileRes['full_name'] ?? 'New User',
        );
      }
    }
  }

  void completeTaskLocally(String reportId, ReportCategory category) {
    final pts = categoryPoints[category] ?? 10;
    state = state.copyWith(
      points: state.points + pts,
      missionsCompleted: state.missionsCompleted + 1,
      completedReportIds: [...state.completedReportIds, reportId],
    );
  }
}

final officerProfileProvider =
    NotifierProvider<OfficerProfileNotifier, Official>(OfficerProfileNotifier.new);
