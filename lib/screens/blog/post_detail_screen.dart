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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
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
      );

      await CommentService.addComment(comment);

      _commentController.clear();
      _nameController.clear();
      _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Post'),
        actions: [
          IconButton(
            icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
            color: _isLiked ? Colors.red : Colors.grey,
            onPressed: _toggleLike,
          ),
          IconButton(
            icon: Icon(Icons.share),
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.post.category.displayName,
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.post.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(widget.post.createdAt),
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.favorite, size: 16, color: Colors.red),
                  SizedBox(width: 4),
                  Text('$_likeCount'),
                  SizedBox(width: 16),
                  Icon(Icons.comment, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text('${_comments.length}'),
                ],
              ),
              SizedBox(height: 24),
              MarkdownBody(
                data: widget.post.content,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(context).textTheme.bodyLarge,
                  h1: Theme.of(context).textTheme.headlineLarge,
                  h2: Theme.of(context).textTheme.headlineMedium,
                  h3: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Divider(thickness: 1, height: 40),
              _buildCommentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${_comments.length})',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Anonymous',
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    hintText: 'Share your thoughts...',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addComment,
                    child: Text('Post Comment'),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        if (_isLoading)
          Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          Center(
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
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: EdgeInsets.all(12),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            comment.commenterName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Text(
                            DateFormat('MMM dd, yyyy').format(comment.createdAt),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(comment.commentText),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}