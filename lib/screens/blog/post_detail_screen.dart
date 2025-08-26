import 'package:blog/services/auth_service.dart';
import 'package:blog/utils/social_share_util.dart';
import 'package:blog/widgets/blinking_background.dart';
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
  CommentSortType _sortType = CommentSortType.top;
  Map<String, String> _userVotes = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfLiked();
    _loadUserVotes();
    _likeCount = widget.post.likesCount;
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments =
          await CommentService.getCommentsForPost(widget.post.id, sortBy: _sortType);
      if (mounted) {
        setState(() => _comments = comments);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading comments: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadUserVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final votes = prefs.getStringList('comment_votes') ?? [];
    if (mounted) {
      setState(() {
        _userVotes = {for (var v in votes) v.split(':')[0]: v.split(':')[1]};
      });
    }
  }

  Future<void> _saveUserVote(String commentId, String voteType) async {
    final prefs = await SharedPreferences.getInstance();
    _userVotes[commentId] = voteType;
    final votesList =
        _userVotes.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('comment_votes', votesList);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleVote(String commentId, String voteType) async {
    final currentVote = _userVotes[commentId];
    if (currentVote == voteType) return;

    try {
      if (voteType == 'up') {
        await CommentService.upvoteComment(commentId);
      } else {
        await CommentService.downvoteComment(commentId);
      }
      _saveUserVote(commentId, voteType);
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error voting: $e')),
        );
      }
    }
  }

  Future<void> _checkIfLiked() async {
    final prefs = await SharedPreferences.getInstance();
    final likedPosts = prefs.getStringList('liked_posts') ?? [];
    if (mounted) {
      setState(() {
        _isLiked = likedPosts.contains(widget.post.id);
      });
    }
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

    try {
      if (_isLiked) {
        await PostService.incrementLikes(widget.post.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_isLiked) {
            likedPosts.remove(widget.post.id);
            _likeCount--;
            _isLiked = false;
          } else {
            likedPosts.add(widget.post.id);
            _likeCount++;
            _isLiked = true;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating like status: $e'),
              backgroundColor: Colors.red),
        );
      }
      await prefs.setStringList('liked_posts', likedPosts);
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
      if (mounted) {
        setState(() {
          _replyingTo = null;
        });
      }
      _loadComments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CommentService.deleteComment(commentId);
        _loadComments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting comment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _enhanceMarkdownSpacing(String content) {
    return content
        .replaceAll('\r\n', '\n')
        .replaceAll('\n\n', '\n\n&nbsp;\n\n')
        .replaceAll(RegExp(r'\n{4,}'), '\n\n&nbsp;\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
      body: Stack(
        children: [
          if (isDarkMode)
            const Positioned.fill(child: BlinkingDotsBackground()),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMMM dd, yyyy')
                            .format(widget.post.createdAt),
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
                  MarkdownBody(
                    data: _enhanceMarkdownSpacing(widget.post.content),
                    styleSheet: MarkdownStyleSheet.fromTheme(
                      Theme.of(context),
                    ).copyWith(
                      p: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.8),
                      h1: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      h2: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      h3: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                      h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
                      blockquotePadding: const EdgeInsets.all(16),
                    ),
                    softLineBreak: false,
                  ),
                  const Divider(thickness: 1, height: 40),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    final topLevelComments =
        _comments.where((c) => c.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Comments (${_comments.length})',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            PopupMenuButton<CommentSortType>(
              initialValue: _sortType,
              onSelected: (CommentSortType item) {
                setState(() {
                  _sortType = item;
                });
                _loadComments();
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<CommentSortType>>[
                const PopupMenuItem<CommentSortType>(
                  value: CommentSortType.top,
                  child: Text('Top'),
                ),
                const PopupMenuItem<CommentSortType>(
                  value: CommentSortType.newest,
                  child: Text('Newest'),
                ),
              ],
              icon: const Icon(Icons.sort),
            ),
          ],
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
                      Expanded(
                        child: Text(
                            "Replying to ${_comments.firstWhere((c) => c.id == _replyingTo).commenterName}",
                            style:
                                const TextStyle(fontStyle: FontStyle.italic)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
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
                  Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
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
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topLevelComments.length,
            itemBuilder: (context, index) {
              final comment = topLevelComments[index];
              return _CommentItem(
                key: ValueKey(comment.id),
                comment: comment,
                allComments: _comments,
                userVote: _userVotes[comment.id],
                onReply: (commentId) {
                  setState(() => _replyingTo = commentId);
                },
                onDelete: _deleteComment,
                onVote: _handleVote,
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

class _CommentItem extends StatefulWidget {
  final CommentModel comment;
  final List<CommentModel> allComments;
  final String? userVote;
  final Function(String) onReply;
  final Function(String) onDelete;
  final Function(String, String) onVote;
  final int depth;

  const _CommentItem({
    super.key,
    required this.comment,
    required this.allComments,
    this.userVote,
    required this.onReply,
    required this.onDelete,
    required this.onVote,
    this.depth = 0,
  });

  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final replies = widget.allComments
        .where((c) => c.parentId == widget.comment.id)
        .toList();
    final voteCount = widget.comment.upvotes - widget.comment.downvotes;

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
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
                          widget.comment.commenterName[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.comment.commenterName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy')
                            .format(widget.comment.createdAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.comment.commentText),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward,
                            color: widget.userVote == 'up'
                                ? Colors.green
                                : Colors.grey),
                        onPressed: () => widget.onVote(widget.comment.id, 'up'),
                      ),
                      Text('$voteCount'),
                      IconButton(
                        icon: Icon(Icons.arrow_downward,
                            color: widget.userVote == 'down'
                                ? Colors.red
                                : Colors.grey),
                        onPressed: () =>
                            widget.onVote(widget.comment.id, 'down'),
                      ),
                      const Spacer(),
                      if (replies.isNotEmpty)
                        TextButton(
                          child: Text(_isExpanded
                              ? 'Hide Replies (${replies.length})'
                              : 'View Replies (${replies.length})'),
                          onPressed: () {
                            setState(() => _isExpanded = !_isExpanded);
                          },
                        ),
                      TextButton(
                        child: const Text('Reply'),
                        onPressed: () => widget.onReply(widget.comment.id),
                      ),
                      if (AuthService.isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () => widget.onDelete(widget.comment.id),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && replies.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: replies.length,
              itemBuilder: (context, index) {
                return _CommentItem(
                  key: ValueKey(replies[index].id),
                  comment: replies[index],
                  allComments: widget.allComments,
                  userVote: widget.userVote,
                  onReply: widget.onReply,
                  onDelete: widget.onDelete,
                  onVote: widget.onVote,
                  depth: widget.depth + 1,
                );
              },
            ),
        ],
      ),
    );
  }
}
