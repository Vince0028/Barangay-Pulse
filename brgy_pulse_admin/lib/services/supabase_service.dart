import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;
  static bool _isConfigured = false;

  static bool get isConfigured => _isConfigured;
  static SupabaseClient get client => _client ?? Supabase.instance.client;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('[SupabaseService] .env not found: $e');
      return;
    }

    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    debugPrint('[SupabaseService] URL: $url');
    debugPrint('[SupabaseService] Key length: ${anonKey.length}');

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint('[SupabaseService] Empty URL or key — demo mode');
      return;
    }

    if (url.contains('your-project') || anonKey.contains('your-anon-key')) {
      debugPrint('[SupabaseService] Placeholder values detected — demo mode');
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _client = Supabase.instance.client;
      _isConfigured = true;
      debugPrint('[SupabaseService] Initialized successfully');
    } catch (e) {
      debugPrint('[SupabaseService] Init error: $e');
    }
  }

  static User? get currentUser => _isConfigured ? client.auth.currentUser : null;
  static bool get isLoggedIn => currentUser != null;

  static Future<AuthResponse> signIn(String email, String password) async {
    if (!_isConfigured) {
      throw Exception('Supabase not configured. Check your .env file.');
    }
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    if (!_isConfigured) {
      throw Exception('Supabase not configured. Check your .env file.');
    }
    return await client.auth.signUp(email: email, password: password, data: data);
  }

  static Future<void> signOut() async {
    if (_isConfigured) {
      await client.auth.signOut();
    }
  }
}
