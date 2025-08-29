import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/about_model.dart';
import '../../services/about_service.dart';
import 'package:image_picker/image_picker.dart';

class EditAboutTab extends StatefulWidget {
  const EditAboutTab({super.key});

  @override
  EditAboutTabState createState() => EditAboutTabState();
}

class EditAboutTabState extends State<EditAboutTab> {
  final _contentController = TextEditingController();
  bool _isLoading = false;
  AboutModel? _aboutModel;
  XFile? _image;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadAboutContent();
  }

  Future<void> _loadAboutContent() async {
    setState(() => _isLoading = true);
    try {
      final content = await AboutService.getAboutContent();
      if (content != null) {
        setState(() {
          _aboutModel = content;
          _contentController.text = content.content;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading about content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _image = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _saveAboutContent() async {
    setState(() => _isLoading = true);
    try {
      String? profilePictureUrl = _aboutModel?.profilePictureUrl;
      if (_image != null) {
        profilePictureUrl = await AboutService.uploadProfilePicture(_image!);
      }

      final updatedAbout = AboutModel(
        id: _aboutModel?.id ?? '1',
        content: _contentController.text.trim(),
        profilePictureUrl: profilePictureUrl,
      );

      await AboutService.updateAboutContent(updatedAbout);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('About page updated!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAboutContent();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving about content: $e'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit About Page',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildStyledCard(
              context,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (_aboutModel?.profilePictureUrl != null
                                  ? NetworkImage(
                                      _aboutModel!.profilePictureUrl!,
                                    )
                                  : null)
                              as ImageProvider?,
                      child: _image == null &&
                              _aboutModel?.profilePictureUrl == null
                          ? const Icon(Icons.person_add_alt_1, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'About Content (Markdown supported)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 15,
                    minLines: 10,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAboutContent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.teal,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save About Page'),
                    ),
                  ),
                ],
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
            color: Colors.black.withValues(alpha:isDarkMode ? 0.2 : 0.04),
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
    _contentController.dispose();
    super.dispose();
  }
}
