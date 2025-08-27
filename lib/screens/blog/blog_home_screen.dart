import 'package:blog/utils/reading_time_util.dart';
import 'package:blog/widgets/blinking_background.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import 'post_detail_screen.dart';

class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({super.key});

  @override
  BlogHomeScreenState createState() => BlogHomeScreenState();
}

class BlogHomeScreenState extends State<BlogHomeScreen> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  PostCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      List<PostModel> posts;
      if (_selectedCategory != null) {
        posts = await PostService.getPostsByCategory(_selectedCategory!);
      } else {
        posts = await PostService.getAllPublishedPosts();
      }
      setState(() => _posts = posts);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading posts: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        if (isDarkMode) const Positioned.fill(child: BlinkingDotsBackground()),
        Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  FilterChip(
                    label: Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = null);
                      _loadPosts();
                    },
                  ),
                  SizedBox(width: 8),
                  ...PostCategory.values.map(
                    (category) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.displayName),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(
                            () =>
                                _selectedCategory = selected ? category : null,
                          );
                          _loadPosts();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No posts available',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text('Check back later for new content'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PostDetailScreen(post: post),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        post.category.displayName,
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      post.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      post.excerpt ??
                                          '${post.content.substring(0, post.content.length > 150 ? 150 : post.content.length)}...',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(post.createdAt),
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          ReadingTimeUtil.calculateReadingTime(
                                            post.content,
                                          ),
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.favorite_border,
                                              size: 14,
                                              color: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${post.likesCount}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
