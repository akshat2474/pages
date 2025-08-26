import '../config/supabase_config.dart';
import '../models/post_model.dart';

class PostService {
  static final _client = SupabaseConfig.client;

  static Future<List<PostModel>> getAllPublishedPosts() async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .eq('published', true)
          .order('created_at', ascending: false);

      return response
          .map<PostModel>((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts: ${e.toString()}');
    }
  }

  static Future<PostModel?> getPostBySlug(String slug) async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .eq('slug', slug)
          .eq('published', true)
          .maybeSingle();

      if (response == null) return null;
      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch post: ${e.toString()}');
    }
  }

  static Future<List<PostModel>> getPostsByCategory(
    PostCategory category,
  ) async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .eq('category', category.value)
          .eq('published', true)
          .order('created_at', ascending: false);

      return response
          .map<PostModel>((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch posts by category: ${e.toString()}');
    }
  }

  static Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await _client
          .from('posts')
          .insert(post.toJson())
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  static Future<PostModel> updatePost(PostModel post) async {
    try {
      final response = await _client
          .from('posts')
          .update(post.toJson())
          .eq('id', post.id)
          .select()
          .single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update post: ${e.toString()}');
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      await _client.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: ${e.toString()}');
    }
  }

  static Future<void> incrementLikes(String postId) async {
    try {
      await _client.rpc('increment_likes', params: {'post_id': postId});
    } catch (e) {
      throw Exception('Failed to increment likes: ${e.toString()}');
    }
  }

  static Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .textSearch('search_vector', query)
          .eq('published', true)
          .order('created_at', ascending: false);

      return response
          .map<PostModel>((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search posts: ${e.toString()}');
    }
  }
}
