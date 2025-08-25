import 'package:blog/utils/social_share_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../services/comment_service.dart';
import '../../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  int _likeCount = 0;
  String? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfLiked();
    _likeCount = widget.post.likesCount;
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await CommentService.getCommentsForPost(widget.post.id);
      setState(() => _comments = comments);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPosts = prefs.getStringList('liked_posts') ?? [];
    setState(() {
      _isLiked = likedPosts.contains(widget.post.id);
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedPosts = prefs.getStringList('liked_posts') ?? [];

    setState(() {
      if (_isLiked) {
        likedPosts.remove(widget.post.id);
        _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
      } else {
        likedPosts.add(widget.post.id);
        _likeCount++;
      }
      _isLiked = !_isLiked;
    });

    await prefs.setStringList('liked_posts', likedPosts);

    if (_isLiked) {
      try {
        await PostService.incrementLikes(widget.post.id);
      } catch (e) {
        print('Error incrementing likes: $e');
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = CommentModel(
        postId: widget.post.id,
        commenterName: _nameController.text.trim().isEmpty
            ? 'Anonymous'
            : _nameController.text.trim(),
        commentText: _commentController.text.trim(),
        parentId: _replyingTo,
      );

      await CommentService.addComment(comment);

      _commentController.clear();
      _nameController.clear();
      setState(() {
        _replyingTo = null;
      });
      _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding comment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Enhanced markdown spacing function
  String _enhanceMarkdownSpacing(String content) {
    return content
        .replaceAll('\r\n', '\n') // Normalize line endings
        .replaceAll('\n\n', '\n\n&nbsp;\n\n') // Add extra space between paragraphs
        .replaceAll(RegExp(r'\n{4,}'), '\n\n&nbsp;\n\n'); // Clean up excessive breaks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Post'),
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            color: _isLiked ? Colors.red : Colors.grey,
            onPressed: _toggleLike,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => SocialShareUtil.sharePost(widget.post),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.post.category.displayName,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.post.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(widget.post.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.favorite, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('$_likeCount'),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text('${_comments.length}'),
                ],
              ),
              const SizedBox(height: 24),
              
              // UPDATED: Use enhanced markdown spacing with MarkdownBody
              MarkdownBody(
                data: _enhanceMarkdownSpacing(widget.post.content),
                styleSheet: MarkdownStyleSheet.fromTheme(
                  Theme.of(context),
                ).copyWith(
                  p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.8, // Increased line height for better readability
                  ),
                  h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                  h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
                  blockquotePadding: const EdgeInsets.all(16),
                ),
                softLineBreak: false, // Turn off to force paragraph breaks
              ),
              
              const Divider(thickness: 1, height: 40),
              _buildCommentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    final topLevelComments = _comments.where((c) => c.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${_comments.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_replyingTo != null)
                  Row(
                    children: [
                      Text("Replying to ${_comments.firstWhere((c) => c.id == _replyingTo).commenterName}"),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _replyingTo = null;
                          });
                        },
                      )
                    ],
                  ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Anonymous',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    hintText: 'Share your thoughts...',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Post Comment'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (topLevelComments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text('No comments yet'),
                  Text('Be the first to share your thoughts!'),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: topLevelComments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(topLevelComments[index]);
            },
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment, {int depth = 0}) {
    final replies = _comments.where((c) => c.parentId == comment.id).toList();
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.teal,
                        child: Text(
                          comment.commenterName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        comment.commenterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy').format(comment.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(comment.commentText),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text('Reply'),
                      onPressed: () {
                        setState(() {
                          _replyingTo = comment.id;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (replies.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              itemBuilder: (context, index) {
                return _buildCommentItem(replies[index], depth: depth + 1);
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}