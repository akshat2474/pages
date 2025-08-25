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
              backgroundColor: Colors.red),
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
        title: Text('About Me'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _aboutModel == null
              ? Center(
                  child: Text('No content available.'),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 900),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.0),
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
        SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello!',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              MarkdownBody(
                data: _aboutModel!.content,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  Theme.of(context),
                ).copyWith(
                  p: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.6),
                ),
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
        SizedBox(height: 24),
        MarkdownBody(
          data: _aboutModel!.content,
          styleSheet: MarkdownStyleSheet.fromTheme(
            Theme.of(context),
          ).copyWith(
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}