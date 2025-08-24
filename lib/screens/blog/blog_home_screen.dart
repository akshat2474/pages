import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import 'post_detail_screen.dart';

class BlogHomeScreen extends StatefulWidget {
  const BlogHomeScreen({super.key});

  @override
  _BlogHomeScreenState createState() => _BlogHomeScreenState();
}

class _BlogHomeScreenState extends State<BlogHomeScreen> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category filter
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
              ...PostCategory.values.map((category) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.displayName),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = selected ? category : null);
                    _loadPosts();
                  },
                ),
              )),
            ],
          ),
        ),

        // Posts list
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No posts available', style: Theme.of(context).textTheme.headlineSmall),
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
                                    builder: (context) => PostDetailScreen(post: post),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category tag
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

                                    // Title
                                    Text(
                                      post.title,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    SizedBox(height: 8),

                                    // Excerpt or content preview
                                    Text(
                                      post.excerpt ?? '${post.content.substring(0, post.content.length > 150 ? 150 : post.content.length)}...',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 12),

                                    // Meta info
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(post.createdAt),
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                        Spacer(),
                                        Icon(Icons.favorite, size: 16, color: Colors.red),
                                        SizedBox(width: 4),
                                        Text('${post.likesCount}'),
                                        SizedBox(width: 16),
                                        Icon(Icons.visibility, size: 16, color: Colors.blue),
                                        SizedBox(width: 4),
                                        Text('${post.viewsCount}'),
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
    );
  }
}
