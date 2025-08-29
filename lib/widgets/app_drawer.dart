import 'package:blog/config/supabase_config.dart';
import 'package:blog/config/theme_provider.dart';
import 'package:blog/screens/about_page.dart';
import 'package:blog/screens/admin/admin_login_screen.dart';
import 'package:blog/screens/blog/blog_home_screen.dart';
import 'package:blog/services/auth_service.dart';
import 'package:blog/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E293B)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                  ),
                  child: Center(
                    child: Text(
                      'MindJourney',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  text: 'About',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AboutPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.article_outlined,
                  text: 'Articles',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: const Text('All Articles')),
                          body: const BlogHomeScreen(),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(indent: 16, endIndent: 16),
                StreamBuilder<AuthState>(
                  stream: SupabaseConfig.client.auth.onAuthStateChange,
                  builder: (context, snapshot) {
                    if (AuthService.isAdmin) {
                      return _buildDrawerItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        text: 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            FadePageRoute(page: const AdminDashboard()),
                          );
                        },
                      );
                    } else {
                      return _buildDrawerItem(
                        context,
                        icon: Icons.person_outline,
                        text: 'Admin Login',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            SlideUpPageRoute(page: const AdminLoginScreen()),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: .5)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toggle Theme',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Icon(
                    isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String text, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color),
      title: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}

