import '../models/report_model.dart';
import '../services/supabase_service.dart';

class AdminReportRepository {
  static Future<List<Report>> fetchAll() async {
    if (!SupabaseService.isConfigured) return [];
    
    final res = await SupabaseService.client
        .from('reports')
        .select()
        .order('created_at', ascending: false);
        
    return (res as List).map((e) => Report.fromJson(e)).toList();
  }

  static Future<void> updateStatus(String id, ReportStatus status, {String? notes}) async {
    if (!SupabaseService.isConfigured) return;
    
    final data = <String, dynamic>{'status': Report.statusToStr(status)};
    if (notes != null) data['admin_notes'] = notes;
    if (status == ReportStatus.pending) {
      data['claimed_by'] = null;
      data['claimed_at'] = null;
    }
    
    await SupabaseService.client.from('reports').update(data).eq('id', id);
  }
  
  static Future<void> claimReport(String id) async {
    if (!SupabaseService.isConfigured) return;
    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return;
    
    await SupabaseService.client.from('reports').update({
      'status': Report.statusToStr(ReportStatus.inProgress),
      'claimed_by': uid,
      'claimed_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
  
  static Future<void> resolveReport(String id) async {
    if (!SupabaseService.isConfigured) return;
    
    await SupabaseService.client.from('reports').update({
      'status': Report.statusToStr(ReportStatus.resolved),
      'resolved_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
  
  static Future<void> unclaimReport(String id) async {
    if (!SupabaseService.isConfigured) return;
    
    await SupabaseService.client.from('reports').update({
      'status': Report.statusToStr(ReportStatus.pending),
      'claimed_by': null,
      'claimed_at': null,
    }).eq('id', id);
  }
}
