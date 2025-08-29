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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'MindJourney',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Articles'),
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
          const Divider(),
          // Admin Login / Dashboard Link
          StreamBuilder<AuthState>(
            stream: SupabaseConfig.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              if (AuthService.isAdmin) {
                return ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      FadePageRoute(page: const AdminDashboard()),
                    );
                  },
                );
              } else {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Admin Login'),
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
          const Divider(),
          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                title: const Text('Toggle Theme'),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
