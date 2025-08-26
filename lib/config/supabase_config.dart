import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static late Supabase _instance;

  static SupabaseClient get client => _instance.client;

  static Future<void> initialize() async {
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const adminEmail = String.fromEnvironment('ADMIN_EMAIL');

    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL environment variable is required');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY environment variable is required');
    }
    if (adminEmail.isEmpty) {
      throw Exception('ADMIN_EMAIL environment variable is required');
    }

    _instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  static String get adminEmail => const String.fromEnvironment('ADMIN_EMAIL');
}
