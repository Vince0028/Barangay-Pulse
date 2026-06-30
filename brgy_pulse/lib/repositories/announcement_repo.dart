import '../models/announcement_model.dart';
import '../services/supabase_service.dart';

class AnnouncementRepository {
  static Future<List<Announcement>> fetchAll() async {
    if (!SupabaseService.isConfigured) return [];

    final res = await SupabaseService.client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);

    return (res as List).map((e) => Announcement.fromJson(e)).toList();
  }
}
