import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'screens/blog/noter_home_screen.dart';  // Use Noter home

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await SupabaseConfig.initialize();
    runApp(MyBlogApp());
  } catch (e) {
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyBlogApp extends StatelessWidget {
  const MyBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindJourney',
      theme: AppTheme.noterTheme,  // Use Noter theme
      home: NoterHomeScreen(),     // Use Noter layout
      debugShowCheckedModeBanner: false,
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({Key? key, required this.error}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.noterTheme,
      home: Scaffold(
        body: Center(
          child: Container(
            margin: EdgeInsets.all(32),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
