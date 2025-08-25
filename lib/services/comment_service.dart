import '../config/supabase_config.dart';
import '../models/comment_model.dart';

class CommentService {
  static final _client = SupabaseConfig.client;

  static Future<List<CommentModel>> getCommentsForPost(String postId) async {
    try {
      final response = await _client
          .from('comments')
          .select()
          .eq('post_id', postId)
          .eq('approved', true)
          .order('created_at', ascending: false);
      
      return response.map<CommentModel>((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  static Future<CommentModel> addComment(CommentModel comment) async {
    try {
      final response = await _client
          .from('comments')
          .insert(comment.toJson())
          .select()
          .single();
      
      return CommentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  static Future<void> deleteComment(String commentId) async {
    try {
      await _client
          .from('comments')
          .delete()
          .eq('id', commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: ${e.toString()}');
    }
  }

  static Future<CommentModel> approveComment(String commentId) async {
    try {
      final response = await _client
          .from('comments')
          .update({'approved': true})
          .eq('id', commentId)
          .select()
          .single();
      
      return CommentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to approve comment: ${e.toString()}');
    }
  }

  // CORRECTED: Stream with proper filtering
  static Stream<List<CommentModel>> watchCommentsForPost(String postId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .map((data) {
          // Filter the data manually after streaming
          final filteredData = data.where((json) => 
            json['post_id'] == postId && 
            json['approved'] == true
          ).toList();
          
          // Sort by created_at descending
          filteredData.sort((a, b) => 
            DateTime.parse(b['created_at']).compareTo(
              DateTime.parse(a['created_at'])
            )
          );
          
          return filteredData.map<CommentModel>((json) => 
            CommentModel.fromJson(json)
          ).toList();
        });
  }
}