import 'package:flutter/material.dart';
import '../../models/daily_content_model.dart';
import '../../services/daily_content_service.dart';

class DailyContentTab extends StatefulWidget {
  const DailyContentTab({super.key});

  @override
  DailyContentTabState createState() => DailyContentTabState();
}

class DailyContentTabState extends State<DailyContentTab> {
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
        const SnackBar(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Daily Content',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildStyledCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Word of the Day',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(
                    labelText: 'Word',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Resilience',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _definitionController,
                  decoration: const InputDecoration(
                    labelText: 'Definition',
                    border: OutlineInputBorder(),
                    hintText: 'The ability to recover from difficulties...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStyledCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thought of the Day',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _thoughtController,
                  decoration: const InputDecoration(
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveDailyContent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Daily Content'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledCard(BuildContext context, {required Widget child}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFFF1F5F9), Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
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