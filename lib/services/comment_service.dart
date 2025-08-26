import '../config/supabase_config.dart';
import '../models/comment_model.dart';

enum CommentSortType { top, newest }

class CommentService {
  static final _client = SupabaseConfig.client;

  static Future<List<CommentModel>> getCommentsForPost(String postId, {CommentSortType sortBy = CommentSortType.top}) async {
    try {
      // Base query to select approved comments for a specific post
      final queryBuilder = _client
          .from('comments')
          .select()
          .eq('post_id', postId)
          .eq('approved', true);

      // The .order() method returns a different type, so we handle it here.
      final sortedQuery;
      if (sortBy == CommentSortType.newest) {
        sortedQuery = queryBuilder.order('created_at', ascending: false);
      } else { // Default to top
        sortedQuery = queryBuilder.order('upvotes', ascending: false).order('created_at', ascending: false);
      }
      
      final response = await sortedQuery;
      
      return response.map<CommentModel>((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: ${e.toString()}');
    }
  }

  static Future<void> upvoteComment(String commentId) async {
    try {
      await _client.rpc('upvote_comment', params: {'comment_id_to_vote': commentId});
    } catch (e) {
      throw Exception('Failed to upvote comment: $e');
    }
  }

  static Future<void> downvoteComment(String commentId) async {
    try {
      await _client.rpc('downvote_comment', params: {'comment_id_to_vote': commentId});
    } catch (e) {
      throw Exception('Failed to downvote comment: $e');
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
}
