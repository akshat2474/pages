import 'package:flutter/material.dart';
import '../../models/daily_content_model.dart';
import '../../services/daily_content_service.dart';

class DailyContentTab extends StatefulWidget {
  const DailyContentTab({super.key});

  @override
  _DailyContentTabState createState() => _DailyContentTabState();
}

class _DailyContentTabState extends State<DailyContentTab> {
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _thoughtController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTodaysContent();
  }

  Future<void> _loadTodaysContent() async {
    try {
      final content = await DailyContentService.getTodaysContent();
      if (content != null) {
        setState(() {
          _wordController.text = content.wordOfDay ?? '';
          _definitionController.text = content.wordDefinition ?? '';
          _thoughtController.text = content.thoughtOfDay ?? '';
        });
      }
    } catch (e) {
      print('Error loading today\'s content: $e');
    }
  }

  Future<void> _saveDailyContent() async {
    setState(() => _isLoading = true);

    try {
      final content = DailyContentModel(
        date: DateTime.now(),
        wordOfDay: _wordController.text.trim().isEmpty
            ? null
            : _wordController.text.trim(),
        wordDefinition: _definitionController.text.trim().isEmpty
            ? null
            : _definitionController.text.trim(),
        thoughtOfDay: _thoughtController.text.trim().isEmpty
            ? null
            : _thoughtController.text.trim(),
      );

      await DailyContentService.createOrUpdateDailyContent(content);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Daily content saved!'),
          backgroundColor: Colors.green,
        ),
      );

      _loadTodaysContent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Daily Content',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),

          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word of the Day',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _wordController,
                    decoration: InputDecoration(
                      labelText: 'Word',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Resilience',
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _definitionController,
                    decoration: InputDecoration(
                      labelText: 'Definition',
                      border: OutlineInputBorder(),
                      hintText: 'The ability to recover from difficulties...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thought of the Day',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _thoughtController,
                    decoration: InputDecoration(
                      labelText: 'Inspirational Thought',
                      border: OutlineInputBorder(),
                      hintText:
                          'Your mental health is just as important as your physical health...',
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveDailyContent,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Save Daily Content'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _thoughtController.dispose();
    super.dispose();
  }
}
