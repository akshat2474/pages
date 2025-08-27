import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final _client = SupabaseConfig.client;
  static const _anonymousUserIdKey = 'anonymous_user_id';

  static Future<AuthResponse> signInAdmin(String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: SupabaseConfig.adminEmail,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Admin login failed: ${e.toString()}');
    }
  }

  static Future<AuthResponse> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      return response;
    } catch (e) {
      throw Exception('Anonymous sign-in failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  static bool get isAdmin {
    final user = _client.auth.currentUser;
    return user?.email == SupabaseConfig.adminEmail;
  }

  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<String> getUserId() async {
    final currentUser = _client.auth.currentUser;
    // Return the authenticated user's ID if they are logged in.
    if (currentUser != null && !currentUser.isAnonymous) {
      return currentUser.id;
    }

    // Handle anonymous users by creating a persistent ID on their device.
    final prefs = await SharedPreferences.getInstance();
    String? anonId = prefs.getString(_anonymousUserIdKey);
    if (anonId == null) {
      anonId = const Uuid().v4();
      await prefs.setString(_anonymousUserIdKey, anonId);
    }
    return anonId;
  }
}
