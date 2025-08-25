import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/about_model.dart';
import '../services/about_service.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isLoading = true;
  AboutModel? _aboutModel;

  @override
  void initState() {
    super.initState();
    _loadAboutContent();
  }

  Future<void> _loadAboutContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await AboutService.getAboutContent();
      if (mounted) {
        setState(() {
          _aboutModel = content;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading about content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Me'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _aboutModel == null
              ? const Center(child: Text('No content available.'))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          bool isDesktop = constraints.maxWidth > 600;
                          return isDesktop
                              ? _buildDesktopLayout()
                              : _buildMobileLayout();
                        },
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildDesktopLayout() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_aboutModel!.profilePictureUrl != null)
        CircleAvatar(
          radius: 100,
          backgroundImage: NetworkImage(_aboutModel!.profilePictureUrl!),
        ),
      const SizedBox(width: 40),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello!',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // ENHANCED: Better paragraph spacing
            MarkdownBody(
              data: _enhanceMarkdownSpacing(_aboutModel!.content),
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(
                p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8, // Increased from 1.6 for better line spacing
                ),
                // Add spacing for other elements
                h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
                h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
                blockquotePadding: const EdgeInsets.all(16),
              ),
              softLineBreak: false, // Turn off to force paragraph breaks
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildMobileLayout() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (_aboutModel!.profilePictureUrl != null)
        CircleAvatar(
          radius: 80,
          backgroundImage: NetworkImage(_aboutModel!.profilePictureUrl!),
        ),
      const SizedBox(height: 24),
      // ENHANCED: Better paragraph spacing
      MarkdownBody(
        data: _enhanceMarkdownSpacing(_aboutModel!.content),
        styleSheet: MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(
          p: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.8, // Increased line spacing
          ),
          h1Padding: const EdgeInsets.only(top: 16, bottom: 8),
          h2Padding: const EdgeInsets.only(top: 16, bottom: 8),
          blockquotePadding: const EdgeInsets.all(16),
        ),
        softLineBreak: false, // Turn off to force paragraph breaks
      ),
    ],
  );
}

// NEW: Enhanced spacing method
String _enhanceMarkdownSpacing(String content) {
  return content
      .replaceAll('\r\n', '\n') // Normalize line endings
      .replaceAll('\n\n', '\n\n&nbsp;\n\n') // Add extra space between paragraphs
      .replaceAll(RegExp(r'\n{4,}'), '\n\n&nbsp;\n\n'); // Clean up excessive breaks
}



}
