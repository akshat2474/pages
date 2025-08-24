import '../config/supabase_config.dart';
import '../models/daily_content_model.dart';

class DailyContentService {
  static final _client = SupabaseConfig.client;

  static Future<DailyContentModel?> getTodaysContent() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _client
          .from('daily_content')
          .select()
          .eq('date', today)
          .maybeSingle();
      
      if (response == null) return null;
      return DailyContentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch today\'s content: ${e.toString()}');
    }
  }

  static Future<DailyContentModel> createOrUpdateDailyContent(DailyContentModel content) async {
    try {
      final response = await _client
          .from('daily_content')
          .upsert(content.toJson())
          .select()
          .single();
      
      return DailyContentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to save daily content: ${e.toString()}');
    }
  }

  static Future<List<DailyContentModel>> getRecentDailyContent({int limit = 7}) async {
    try {
      final response = await _client
          .from('daily_content')
          .select()
          .order('date', ascending: false)
          .limit(limit);
      
      return response.map<DailyContentModel>((json) => DailyContentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent daily content: ${e.toString()}');
    }
  }
}
