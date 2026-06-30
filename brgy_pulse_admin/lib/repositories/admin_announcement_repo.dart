import '../models/announcement_model.dart';
import '../services/supabase_service.dart';

class AdminAnnouncementRepository {
  static Future<List<Announcement>> fetchAll() async {
    if (!SupabaseService.isConfigured) return [];
    
    // We fetch announcements. In admin, the models are simpler.
    // Assuming we have basic fields matching the table.
    final res = await SupabaseService.client
        .from('announcements')
        .select('*, official:posted_by(role_title, profiles:id(full_name))')
        .order('created_at', ascending: false);
        
    return (res as List).map((e) {
      final posterName = e['official']?['profiles']?['full_name'] as String? ?? 'Official';
      final role = e['official']?['role_title'] as String? ?? '';
      return Announcement(
        id: e['id'] as String,
        title: e['title'] as String,
        body: e['body'] as String,
        postedBy: posterName,
        posterRole: role,
        timestamp: DateTime.parse(e['created_at'] as String),
      );
    }).toList();
  }

  static Future<Announcement> create(String title, String body) async {
    if (!SupabaseService.isConfigured) {
      return Announcement(
        id: 'new', title: title, body: body, postedBy: 'You', posterRole: 'Admin', timestamp: DateTime.now(),
      );
    }
    
    final uid = SupabaseService.currentUser?.id;
    final res = await SupabaseService.client.from('announcements').insert({
      'title': title,
      'body': body,
      'posted_by': uid,
    }).select().single();
    
    return Announcement(
        id: res['id'] as String,
        title: res['title'] as String,
        body: res['body'] as String,
        postedBy: 'You',
        posterRole: 'Admin',
        timestamp: DateTime.parse(res['created_at'] as String),
      );
  }
  
  static Future<void> delete(String id) async {
    if (!SupabaseService.isConfigured) return;
    await SupabaseService.client.from('announcements').delete().eq('id', id);
  }
}
