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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading about content: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('About page updated!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadAboutContent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving about content: $e'),
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
            'Edit About Page',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 16),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : (_aboutModel?.profilePictureUrl != null
                                  ? NetworkImage(
                                      _aboutModel!.profilePictureUrl!,
                                    )
                                  : null)
                              as ImageProvider?,
                    child:
                        _image == null && _aboutModel?.profilePictureUrl == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'About Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 15,
                  minLines: 10,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAboutContent,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Save About Page'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
