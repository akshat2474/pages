import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/daily_content_service.dart';
import '../../models/daily_content_model.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../services/auth_service.dart';
import '../admin/admin_login_screen.dart';
import 'post_detail_screen.dart';
import '../../config/supabase_config.dart';
import '../../config/theme_provider.dart';
import '../../utils/reading_time_util.dart';
import '../../widgets/animated_widgets.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../utils/page_transitions.dart';

class NoterHomeScreen extends StatefulWidget {
  const NoterHomeScreen({super.key});

  @override
  _NoterHomeScreenState createState() => _NoterHomeScreenState();
}

class _NoterHomeScreenState extends State<NoterHomeScreen> {
  DailyContentModel? todaysContent;
  List<PostModel> _featuredPosts = [];
  List<PostModel> _recentPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => isLoading = true);
    try {
      final content = await DailyContentService.getTodaysContent();
      final allPosts = await PostService.getAllPublishedPosts();
      
      setState(() {
        todaysContent = content;
        _featuredPosts = allPosts.take(3).toList();
        _recentPosts = allPosts.skip(3).take(6).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          
          SliverToBoxAdapter(
            child: Column(
              children: [
                FadeInSlideUp(
                  delay: Duration(milliseconds: 200),
                  child: _buildHeroSection(),
                ),
                
                SizedBox(height: 80),
                if (isLoading)
                  DailyContentSkeleton()
                else if (todaysContent != null)
                  FadeInSlideUp(
                    delay: Duration(milliseconds: 400),
                    child: _buildDailyContentSection(),
                  ),
                
                SizedBox(height: 80),
                FadeInSlideUp(
                  delay: Duration(milliseconds: 600),
                  child: _buildFeaturedSection(),
                ),
                
                SizedBox(height: 80),
                FadeInSlideUp(
                  delay: Duration(milliseconds: 800),
                  child: _buildRecentSection(),
                ),
                
                SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MindJourney',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ThemeToggleAnimation(
                    isDarkMode: themeProvider.isDarkMode,
                    onToggle: () => themeProvider.toggleTheme(),
                  );
                },
              ),
              SizedBox(width: 16),
              
              TextButton(
                onPressed: () {},
                child: Text(
                  'About',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
              SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Articles',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              ),
              SizedBox(width: 24),
              StreamBuilder<AuthState>(
                stream: SupabaseConfig.client.auth.onAuthStateChange,
                builder: (context, snapshot) {
                  final session = snapshot.data?.session;
                  
                  if (session != null && AuthService.isAdmin) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          FadePageRoute(page: AdminDashboard()),
                        );
                      },
                      icon: Icon(Icons.dashboard, size: 16),
                      label: Text('Dashboard'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    );
                  } else {
                    return IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          SlideUpPageRoute(page: AdminLoginScreen()),
                        );
                      },
                      icon: Icon(Icons.person_outline),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Text(
              'Mental Health & Wellbeing',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Your journey to\nbetter mental health\nstarts here',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          
          SizedBox(height: 24),
          
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              'Discover insights, tips, and inspiration for your mental wellbeing. A safe space for growth, healing, and self-discovery.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 18,
              ),
            ),
          ),
          
          SizedBox(height: 40),
          
          Row(
            children: [
              PulsatingButton(
                onPressed: () {
                },
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('Read Latest Articles'),
                ),
              ),
              SizedBox(width: 16),
              TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'About This Blog',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyContentSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wb_sunny, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Text(
                'Today\'s Daily Inspiration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          if (todaysContent!.wordOfDay != null) ...[
            _buildWordSection(),
            if (todaysContent!.thoughtOfDay != null) 
              SizedBox(height: 24),
          ],
          
          if (todaysContent!.thoughtOfDay != null) ...[
            _buildThoughtSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildWordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: Theme.of(context).colorScheme.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Word of the Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todaysContent!.wordOfDay!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (todaysContent!.wordDefinition != null) ...[
                SizedBox(height: 8),
                Text(
                  todaysContent!.wordDefinition!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThoughtSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_quote, color: Theme.of(context).colorScheme.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Thought of the Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.format_quote, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7), size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  todaysContent!.thoughtOfDay!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    height: 1.5,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Articles',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 32),
          
          if (isLoading)
            PostListSkeleton(itemCount: 3)
          else if (_featuredPosts.isEmpty)
            _buildEmptyState()
          else
            StaggeredListAnimation(
              children: _featuredPosts.asMap().entries.map((entry) {
                final index = entry.key;
                final post = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: index < _featuredPosts.length - 1 ? 32 : 0),
                  child: _buildFeaturedCard(post, index == 0),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(PostModel post, bool isLarge) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          SlideUpPageRoute(page: PostDetailScreen(post: post)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(post.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Text(
                    post.title,
                    style: isLarge 
                        ? Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600)
                        : Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    post.excerpt ?? '${post.content.substring(0, post.content.length > 120 ? 120 : post.content.length)}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(post.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        ReadingTimeUtil.calculateReadingTime(post.content),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(Icons.favorite_border, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                          SizedBox(width: 4),
                          Text('${post.likesCount}', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (isLarge) ...[
              SizedBox(width: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.article_outlined, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Articles',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 32),
          
          if (isLoading)
            RecentPostsSkeleton(itemCount: 6)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
              ),
              itemCount: _recentPosts.length,
              itemBuilder: (context, index) {
                return ScaleUpAnimation(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildRecentCard(_recentPosts[index]),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(PostModel post) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          ScalePageRoute(page: PostDetailScreen(post: post)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: _getCategoryColor(post.category),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                post.category.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  Spacer(),
                  
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM dd').format(post.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        ReadingTimeUtil.calculateReadingTime(post.content),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 48, color: Theme.of(context).textTheme.bodyMedium?.color),
            SizedBox(height: 16),
            Text(
              'No articles yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Check back soon for new content',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(PostCategory category) {
    switch (category) {
      case PostCategory.mentalHealth:
        return Color(0xFF3B82F6);
      case PostCategory.selfHelp:
        return Color(0xFF10B981);
      case PostCategory.sliceOfLife:
        return Color(0xFF8B5CF6);
    }
  }
}
