import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/about_model.dart';
import 'package:image_picker/image_picker.dart';

class AboutService {
  static final _client = SupabaseConfig.client;

  static Future<AboutModel?> getAboutContent() async {
    try {
      final response = await _client.from('about').select().maybeSingle();
      if (response == null) return null;
      return AboutModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch about content: ${e.toString()}');
    }
  }

  static Future<AboutModel> updateAboutContent(AboutModel about) async {
    try {
      final response = await _client
          .from('about')
          .upsert(about.toJson())
          .select()
          .single();
      return AboutModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update about content: ${e.toString()}');
    }
  }

  static Future<String> uploadProfilePicture(XFile image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}.${image.name.split('.').last}';

      await _client.storage
          .from('pfp')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: image.mimeType,
            ),
          );

      return _client.storage.from('pfp').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString()}');
    }
  }
}
