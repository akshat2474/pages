import 'package:flutter/material.dart';
import '../../services/daily_content_service.dart';
import '../../models/daily_content_model.dart';
import '../admin/admin_login_screen.dart';  // Import AdminLoginScreen
import 'blog_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DailyContentModel? todaysContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTodaysContent();
  }

  Future<void> _loadTodaysContent() async {
    try {
      final content = await DailyContentService.getTodaysContent();
      setState(() {
        todaysContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading today\'s content: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mental Health Blog'),
        actions: [
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.home), text: 'Daily'),
            Tab(icon: Icon(Icons.article), text: 'Blog Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Daily content tab
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (todaysContent != null)
                  _buildDailyContentCard()
                else
                  _buildEmptyDailyContent(),
                
                SizedBox(height: 20),
                
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Your Mental Health Journey',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This is a safe space for mental health awareness, self-help tips, and daily reflections. Start your journey towards better mental wellbeing.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Blog posts tab
          BlogHomeScreen(),
        ],
      ),
    );
  }

  Widget _buildDailyContentCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todaysContent!.wordOfDay != null) ...[
              Text(
                'Word of the Day',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 8),
              Text(
                todaysContent!.wordOfDay!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (todaysContent!.wordDefinition != null) ...[
                SizedBox(height: 4),
                Text(
                  todaysContent!.wordDefinition!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              SizedBox(height: 16),
            ],
            
            if (todaysContent!.thoughtOfDay != null) ...[
              Text(
                'Thought of the Day',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${todaysContent!.thoughtOfDay!}"',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDailyContent() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No daily content available yet',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Check back later for today\'s word and thought',
              style: Theme.of(context).textTheme.bodySmall,
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
