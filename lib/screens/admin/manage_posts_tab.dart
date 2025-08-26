import 'package:blog/screens/admin/write_post_tab.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';

class ManagePostsTab extends StatelessWidget {
  final List<PostModel> posts;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ManagePostsTab({
    super.key,
    required this.posts,
    required this.isLoading,
    required this.onRefresh,
  });

  Future<void> _togglePublishStatus(
    BuildContext context,
    PostModel post,
  ) async {
    try {
      final updatedPost = post.copyWith(published: !post.published);
      await PostService.updatePost(updatedPost);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(post.published ? 'Post unpublished' : 'Post published'),
          backgroundColor: Colors.green,
        ),
      );
      onRefresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletePost(BuildContext context, PostModel post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Post'),
        content: Text('Are you sure you want to delete "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PostService.deletePost(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post deleted'),
            backgroundColor: Colors.green,
          ),
        );
        onRefresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('Create your first blog post using the Write Post tab'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                post.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.category.displayName),
                  Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(post.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.red),
                      Text(' ${post.likesCount}'),
                      SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.blue),
                      Text(' ${post.viewsCount}'),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: post.published ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.published ? 'Published' : 'Draft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              post.published
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            SizedBox(width: 8),
                            Text(post.published ? 'Unpublish' : 'Publish'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'toggle') {
                        _togglePublishStatus(context, post);
                      } else if (value == 'delete') {
                        _deletePost(context, post);
                      } else if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(title: Text('Edit Post')),
                              body: WritePostTab(
                                onPostCreated: onRefresh,
                                postToEdit: post,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
