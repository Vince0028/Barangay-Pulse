import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../repositories/report_repository.dart';
import '../services/supabase_service.dart';

class ReportNotifier extends Notifier<List<Report>> {
  @override
  List<Report> build() {
    // Start empty — call refresh() to load from Supabase
    return [];
  }

  Future<void> refresh() async {
    state = await ReportRepository.fetchAll();
  }

  Future<void> addReport(Report report) async {
    final created = await ReportRepository.create(report);
    state = [created, ...state];
  }
}

final reportProvider = NotifierProvider<ReportNotifier, List<Report>>(ReportNotifier.new);

// Derived providers
final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.pending).length;
});

final inProgressCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.inProgress).length;
});

final resolvedCountProvider = Provider<int>((ref) {
  return ref.watch(reportProvider).where((r) => r.status == ReportStatus.resolved).length;
});

final myReportsProvider = Provider<List<Report>>((ref) {
  final uid = SupabaseService.currentUser?.id;
  if (uid == null) return [];
  return ref.watch(reportProvider).where((r) => r.reportedBy == uid).toList();
});

