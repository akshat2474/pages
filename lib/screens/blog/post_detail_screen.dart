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
import '../../utils/reading_time_util.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;
  const PostDetailScreen({super.key, required this.post});

  @override
  PostDetailScreenState createState() => PostDetailScreenState();
}

class PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  int _likeCount = 0;
  String? _replyingTo;
  CommentSortType _sortType = CommentSortType.top;
  Map<String, String> _userVotes = {};
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfLiked();
    _loadUserVotes();
    _likeCount = widget.post.likesCount;

    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 400 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);
    try {
      final comments = await CommentService.getCommentsForPost(
        widget.post.id,
        sortBy: _sortType,
      );
      if (mounted) {
        setState(() => _comments = comments);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
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
    final votesList = _userVotes.entries
        .map((e) => '${e.key}:${e.value}')
        .toList();
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error voting: $e')));
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
            backgroundColor: Colors.red,
          ),
        );

        await prefs.setStringList('liked_posts', likedPosts);
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
        .replaceAll('\n\n', '\n\n \n\n')
        .replaceAll(RegExp(r'\n{4,}'), '\n\n \n\n');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF0F1419)
          : const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          if (isDarkMode)
            const Positioned.fill(child: BlinkingDotsBackground()),

          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildEnhancedAppBar(isDarkMode),

              SliverToBoxAdapter(child: _buildArticleContent(isDarkMode)),

              SliverToBoxAdapter(child: _buildCommentsSection()),
            ],
          ),

          if (_showScrollToTop)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.small(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: isDarkMode ? const Color(0xFF1A202C) : Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [const Color(0xFF1A202C), const Color(0xFF2D3748)]
                  : [Colors.white, const Color(0xFFF7FAFC)],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: _isLiked ? Colors.red.withValues(alpha:0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey,
            ),
            onPressed: _toggleLike,
            tooltip: _isLiked ? 'Unlike' : 'Like',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => SocialShareUtil.sharePost(widget.post),
            tooltip: 'Share',
          ),
        ),
      ],
    );
  }

  Widget _buildArticleContent(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          _buildArticleHeader(isDarkMode),

          const SizedBox(height: 32),

          _buildArticleBody(isDarkMode),

          const SizedBox(height: 48),

          _buildArticleFooter(isDarkMode),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildArticleHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(widget.post.category).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getCategoryColor(widget.post.category).withValues(alpha:0.3),
              ),
            ),
            child: Text(
              widget.post.category.displayName,
              style: TextStyle(
                color: _getCategoryColor(widget.post.category),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            widget.post.title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
              fontSize: 32,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(widget.post.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ReadingTimeUtil.calculateReadingTime(widget.post.content),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: Colors.red.withValues(alpha:0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_likeCount ${_likeCount == 1 ? 'like' : 'likes'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: Colors.blue.withValues(alpha:0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_comments.length} ${_comments.length == 1 ? 'comment' : 'comments'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleBody(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:isDarkMode ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: MarkdownBody(
        data: _enhanceMarkdownSpacing(widget.post.content),
        styleSheet: _buildEnhancedMarkdownStyle(context, isDarkMode),
        softLineBreak: false,
      ),
    );
  }

  MarkdownStyleSheet _buildEnhancedMarkdownStyle(
    BuildContext context,
    bool isDarkMode,
  ) {
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: Theme.of(context).textTheme.bodyLarge?.copyWith(
        height: 1.8,
        fontSize: 18,
        letterSpacing: 0.3,
      ),

      h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 28,
        height: 1.3,
      ),
      h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 1.4,
      ),
      h3: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.4,
      ),

      h1Padding: const EdgeInsets.only(top: 32, bottom: 16),
      h2Padding: const EdgeInsets.only(top: 28, bottom: 12),
      h3Padding: const EdgeInsets.only(top: 24, bottom: 10),
      pPadding: const EdgeInsets.only(bottom: 16),

      blockquote: TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        color: Theme.of(context).textTheme.bodyMedium?.color,
        height: 1.6,
      ),
      blockquotePadding: const EdgeInsets.all(20),
      blockquoteDecoration: BoxDecoration(
        color: _getCategoryColor(widget.post.category).withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _getCategoryColor(widget.post.category),
            width: 4,
          ),
        ),
      ),

      code: TextStyle(
        backgroundColor: isDarkMode
            ? const Color(0xFF2D3748)
            : const Color(0xFFF7FAFC),
        fontFamily: 'Courier',
        fontSize: 16,
      ),
      codeblockPadding: const EdgeInsets.all(16),
      codeblockDecoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF4A5568) : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  Widget _buildArticleFooter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _isLiked
                      ? Colors.red.withValues(alpha:0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isLiked
                        ? Colors.red.withValues(alpha:0.3)
                        : Colors.grey.withValues(alpha:0.3),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleLike,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$_likeCount',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isLiked ? Colors.red : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => SocialShareUtil.sharePost(widget.post),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Share',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha:0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    final topLevelComments = _comments
        .where((c) => c.parentId == null)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A202C)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2D3748)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comments (${_comments.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CommentSortType>(
                    value: _sortType,
                    onChanged: (CommentSortType? newValue) {
                      if (newValue != null) {
                        setState(() => _sortType = newValue);
                        _loadComments();
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: CommentSortType.top,
                        child: Text('Top', style: TextStyle(fontSize: 14)),
                      ),
                      DropdownMenuItem(
                        value: CommentSortType.newest,
                        child: Text('Newest', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                    icon: const Icon(Icons.sort, size: 16),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildEnhancedCommentForm(),

          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (topLevelComments.isEmpty)
            _buildEmptyCommentsState()
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
      ),
    );
  }

  Widget _buildEnhancedCommentForm() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1F2937), const Color(0xFF374151)]
              : [const Color(0xFFFDFDFD), const Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF4B5563).withValues(alpha:0.5)
              : const Color(0xFFE5E7EB).withValues(alpha:0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha:0.3)
                : Colors.black.withValues(alpha:0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _replyingTo != null
                    ? 'Reply to Comment'
                    : 'Join the Discussion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Replying to ${_comments.firstWhere((c) => c.id == _replyingTo).commenterName}",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _replyingTo = null),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.2)
                      : Colors.black.withValues(alpha:0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Your Name',
                hintText: 'Leave empty for Anonymous',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF374151) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF6B7280).withValues(alpha:0.3)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF6B7280).withValues(alpha:0.3)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.2)
                      : Colors.black.withValues(alpha:0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Your Comment',
                hintText: 'Share your thoughts...',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF374151) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF6B7280).withValues(alpha:0.3)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF6B7280).withValues(alpha:0.3)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              maxLines: 4,
              minLines: 3,
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF4B5563), const Color(0xFF6B7280)]
                    : [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withValues(alpha:0.8),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha:0.3)
                      : Theme.of(context).colorScheme.primary.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addComment,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        color: isDarkMode
                            ? Colors.white.withValues(alpha:0.9)
                            : Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _replyingTo != null ? 'Post Reply' : 'Post Comment',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white.withValues(alpha:0.9)
                              : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommentsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.comment_outlined,
            size: 48,
            color: Colors.grey.withValues(alpha:0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No comments yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your thoughts!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(PostCategory category) {
    switch (category) {
      case PostCategory.mentalHealth:
        return const Color(0xFF10B981);
      case PostCategory.selfHelp:
        return const Color(0xFF8B5CF6);
      case PostCategory.sliceOfLife:
        return const Color(0xFFEF4444);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    _scrollController.dispose();
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2D3748)
                  : const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF4A5568)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        widget.comment.commenterName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.comment.commenterName,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • HH:mm',
                            ).format(widget.comment.createdAt),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.comment.commentText,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: widget.userVote == 'up'
                            ? Colors.green.withValues(alpha:0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_up,
                          color: widget.userVote == 'up'
                              ? Colors.green
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => widget.onVote(widget.comment.id, 'up'),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    Text(
                      '$voteCount',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: voteCount > 0
                            ? Colors.green
                            : (voteCount < 0 ? Colors.red : Colors.grey),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.userVote == 'down'
                            ? Colors.red.withValues(alpha:0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: widget.userVote == 'down'
                              ? Colors.red
                              : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            widget.onVote(widget.comment.id, 'down'),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    const Spacer(),

                    TextButton.icon(
                      onPressed: () => widget.onReply(widget.comment.id),
                      icon: const Icon(Icons.reply, size: 16),
                      label: const Text('Reply'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),

                    if (replies.isNotEmpty)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _isExpanded = !_isExpanded);
                        },
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          size: 16,
                        ),
                        label: Text(
                          '${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),

                    if (AuthService.isAdmin)
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        onPressed: () => widget.onDelete(widget.comment.id),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ],
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
