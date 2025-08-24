import 'package:flutter/material.dart';
import 'package:blog/config/supabase_config.dart';
import 'package:blog/screens/blog/home_screen.dart';

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
      title: 'Mental Health Blog',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Georgia',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  
  const ErrorApp({super.key, required this.error});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Configuration Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 16),
              Text('Please check your environment variables', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
