import '../models/report_model.dart';
import '../services/supabase_service.dart';

class ReportRepository {
  static Future<List<Report>> fetchAll() async {
    if (!SupabaseService.isConfigured) return [];

    final res = await SupabaseService.client
        .from('reports')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => Report.fromJson(e)).toList();
  }

  static Future<List<Report>> fetchMine() async {
    if (!SupabaseService.isConfigured) return [];

    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return [];

    final res = await SupabaseService.client
        .from('reports')
        .select()
        .eq('reported_by', uid)
        .order('created_at', ascending: false);

    return (res as List).map((e) => Report.fromJson(e)).toList();
  }

  static Future<Report> create(Report report) async {
    if (!SupabaseService.isConfigured) return report;

    final uid = SupabaseService.currentUser?.id;
    final data = report.toJson();
    data['reported_by'] = uid;

    final res = await SupabaseService.client
        .from('reports')
        .insert(data)
        .select()
        .single();

    return Report.fromJson(res);
  }
}
