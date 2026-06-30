import '../models/official_model.dart';
import '../services/supabase_service.dart';

class OfficialRepository {
  static Future<List<Official>> fetchAll() async {
    if (!SupabaseService.isConfigured) return [];

    final res = await SupabaseService.client
        .from('officials')
        .select('*, profiles(full_name)')
        .eq('is_active', true)
        .order('points', ascending: false);

    return (res as List).map((e) {
      e['full_name'] = e['profiles']?['full_name'];
      return Official.fromJson(e);
    }).toList();
  }

  static Future<void> submitRating(String officialId, int rating) async {
    if (!SupabaseService.isConfigured) return;

    final uid = SupabaseService.currentUser?.id;
    if (uid == null) return;

    await SupabaseService.client.from('ratings').upsert({
      'official_id': officialId,
      'rated_by': uid,
      'rating': rating,
    }, onConflict: 'official_id,rated_by');
  }
}
