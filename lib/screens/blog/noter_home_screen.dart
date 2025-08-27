import 'package:blog/screens/about_page.dart';
import 'package:blog/screens/blog/blog_home_screen.dart';
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
import '../../widgets/blinking_background.dart';
import '../../widgets/footer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GreenUnderline extends StatelessWidget {
  const GreenUnderline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFD3EADD),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class PinkSquiggle extends StatelessWidget {
  const PinkSquiggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final squiggleColor = isDarkMode
        ? const Color(0xFF8B5CF6).withOpacity(0.6)
        : Colors.pink.withOpacity(0.3);

    return SizedBox(
      width: 80,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 10,
            top: -15,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 35,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(color: squiggleColor, width: 2.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: -20,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 35,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: squiggleColor, width: 2.5),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NoterHomeScreen extends StatefulWidget {
  const NoterHomeScreen({super.key});

  @override
  NoterHomeScreenState createState() => NoterHomeScreenState();
}

class NoterHomeScreenState extends State<NoterHomeScreen> {
  DailyContentModel? todaysContent;
  List<PostModel> _featuredPosts = [];
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
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          if (isDarkMode)
            const Positioned.fill(child: BlinkingDotsBackground()),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(isDesktop)),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        FadeInSlideUp(
                          delay: const Duration(milliseconds: 200),
                          child: _buildHeroSection(isDesktop),
                        ),
                        const SizedBox(height: 80),
                        if (isLoading)
                          const DailyContentSkeleton()
                        else if (todaysContent != null)
                          FadeInSlideUp(
                            delay: const Duration(milliseconds: 400),
                            child: _buildDailyContentSection(),
                          ),
                        const SizedBox(height: 80),
                        FadeInSlideUp(
                          delay: const Duration(milliseconds: 600),
                          child: _buildFeaturedSection(isDesktop),
                        ),
                        const SizedBox(height: 80),
                        const Footer(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MindJourney',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (isDesktop)
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
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AboutPage()),
                    );
                  },
                  child: Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('All Articles')),
                          body: const BlogHomeScreen(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Articles',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                StreamBuilder<AuthState>(
                  stream: SupabaseConfig.client.auth.onAuthStateChange,
                  builder: (context, snapshot) {
                    final session = snapshot.data?.session;

                    if (session != null && AuthService.isAdmin) {
                      return ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(FadePageRoute(page: const AdminDashboard()));
                        },
                        icon: const Icon(Icons.dashboard, size: 16),
                        label: const Text('Dashboard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    } else {
                      return IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            SlideUpPageRoute(page: const AdminLoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.person_outline),
                      );
                    }
                  },
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // TODO: implement drawer
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    final heroTextStyle = isDesktop
        ? Theme.of(context).textTheme.displayLarge
        : Theme.of(context).textTheme.displayMedium;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              ),
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
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              RichText(
                text: TextSpan(
                  style: heroTextStyle,
                  children: const [
                    TextSpan(text: 'Scribbled thoughts and views on\n'),
                    TextSpan(text: 'life and culture'),
                  ],
                ),
              ),
              Positioned(bottom: 5, left: 0, child: const GreenUnderline()),
              if (isDesktop)
                Positioned(top: -5, right: 110, child: const PinkSquiggle()),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isDesktop ? MediaQuery.of(context).size.width * 0.6 : null,
            child: Text(
              'Discover insights, tips, and inspiration for your mental wellbeing. A safe space for growth, healing, and self-discovery.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              PulsatingButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: const Text('All Articles')),
                        body: const BlogHomeScreen(),
                      ),
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('All Articles')),
                          body: const BlogHomeScreen(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Read Latest Articles'),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => AboutPage()));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'About This Blog',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=100&h=100&fit=crop&crop=center',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(width: 48, height: 48, color: Colors.grey[300]),
                  errorWidget: (context, url, error) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Today\'s Daily Inspiration',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF63C4B6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (todaysContent!.wordOfDay != null) ...[
            _buildWordSection(),
            if (todaysContent!.thoughtOfDay != null) const SizedBox(height: 24),
          ],
          if (todaysContent!.thoughtOfDay != null) ...[_buildThoughtSection()],
        ],
      ),
    );
  }

  Widget _buildWordSection() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              color: const Color(0xFF63C4B6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Word of the Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF63C4B6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFFD3EADD).withOpacity(0.1)
                : const Color(0xFFF0F7F6),
            borderRadius: BorderRadius.circular(12),
            border: isDarkMode
                ? Border.all(color: const Color(0xFF63C4B6).withOpacity(0.4))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todaysContent!.wordOfDay!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (todaysContent!.wordDefinition != null) ...[
                const SizedBox(height: 8),
                Text(
                  todaysContent!.wordDefinition!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? Colors.white70
                        : Theme.of(context).textTheme.bodyLarge?.color,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.format_quote, color: const Color(0xFF63C4B6), size: 20),
            const SizedBox(width: 8),
            Text(
              'Thought of the Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF63C4B6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFFD3EADD).withOpacity(0.1)
                : const Color(0xFFF0F7F6),
            borderRadius: BorderRadius.circular(12),
            border: isDarkMode
                ? Border.all(color: const Color(0xFF63C4B6).withOpacity(0.4))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.format_quote,
                color: const Color(0xFF63C4B6).withOpacity(0.7),
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  todaysContent!.thoughtOfDay!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDarkMode
                        ? Colors.white70
                        : Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildFeaturedSection(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured Articles',
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const PostListSkeleton(itemCount: 3)
          else if (_featuredPosts.isEmpty)
            _buildEmptyState()
          else if (isDesktop)
            StaggeredListAnimation(
              children: _featuredPosts.asMap().entries.map((entry) {
                final index = entry.key;
                final post = entry.value;
                return Container(
                  margin: EdgeInsets.only(
                    bottom: index < _featuredPosts.length - 1 ? 32 : 0,
                  ),
                  child: _buildFeaturedCard(post, index == 0),
                );
              }).toList(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _featuredPosts.length,
              itemBuilder: (context, index) {
                final post = _featuredPosts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: _buildFeaturedCard(post, false),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(PostModel post, bool isLarge) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(SlideUpPageRoute(page: PostDetailScreen(post: post)));
      },
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade200
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(post.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post.title,
                    style: isLarge
                        ? Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          )
                        : Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    post.excerpt ??
                        '${post.content.substring(0, post.content.length > 120 ? 120 : post.content.length)}...',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(post.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ReadingTimeUtil.calculateReadingTime(post.content),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          const SizedBox(width: 4),
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
            if (isLarge) ...[
              const SizedBox(width: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
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
        return const Color(0xFF3B82F6);
      case PostCategory.selfHelp:
        return const Color(0xFF10B981);
      case PostCategory.sliceOfLife:
        return const Color(0xFF8B5CF6);
    }
  }
}
