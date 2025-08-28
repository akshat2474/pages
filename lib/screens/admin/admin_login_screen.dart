import 'package:blog/screens/admin/edit_about_tab.dart';
import 'package:blog/screens/blog/noter_home_screen.dart';
import 'package:blog/widgets/blinking_background.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/post_model.dart';
import '../../config/supabase_config.dart';
import 'write_post_tab.dart';
import 'manage_posts_tab.dart';
import 'daily_content_tab.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  AdminLoginScreenState createState() => AdminLoginScreenState();
}

class AdminLoginScreenState extends State<AdminLoginScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signInAdmin(_passwordController.text.trim());

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (isDarkMode)
            const Positioned.fill(child: BlinkingDotsBackground()),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [
                              const Color(0xFF1E293B),
                              const Color(0xFF0F172A)
                            ]
                          : [const Color(0xFFF1F5F9), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Admin Access',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your password to access the dashboard',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        onSubmitted: (_) => _signIn(),
                      ),
                      const SizedBox(height: 16),
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Login'),
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
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<PostModel> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseConfig.client
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _posts = response
            .map<PostModel>((json) => PostModel.fromJson(json))
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading posts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const NoterHomeScreen()),
                  (route) => false,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await AuthService.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NoterHomeScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.edit_outlined), text: 'Write Post'),
              Tab(icon: Icon(Icons.list_alt_outlined), text: 'Manage Posts'),
              Tab(icon: Icon(Icons.today_outlined), text: 'Daily Content'),
              Tab(icon: Icon(Icons.person_outline), text: 'About'),
            ],
          ),
        ),
        body: Stack(
          children: [
            if (isDarkMode)
              const Positioned.fill(child: BlinkingDotsBackground()),
            TabBarView(
              controller: _tabController,
              children: [
                WritePostTab(onPostCreated: _loadPosts),
                ManagePostsTab(
                  posts: _posts,
                  isLoading: _isLoading,
                  onRefresh: _loadPosts,
                ),
                const DailyContentTab(),
                const EditAboutTab(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}