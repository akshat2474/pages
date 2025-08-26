import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';

class WritePostTab extends StatefulWidget {
  final VoidCallback onPostCreated;
  final PostModel? postToEdit;

  const WritePostTab({
    super.key,
    required this.onPostCreated,
    this.postToEdit,
  });

  @override
  _WritePostTabState createState() => _WritePostTabState();
}

class _WritePostTabState extends State<WritePostTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  PostCategory _selectedCategory = PostCategory.mentalHealth;
  bool _isPublished = false;
  bool _isLoading = false;
  bool get _isEditing => widget.postToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.postToEdit!.title;
      _contentController.text = widget.postToEdit!.content;
      _excerptController.text = widget.postToEdit!.excerpt ?? '';
      _selectedCategory = widget.postToEdit!.category;
      _isPublished = widget.postToEdit!.published;
    }
  }

  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .trim();
  }

  Future<void> _savePost() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Title and content are required'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updatedPost = widget.postToEdit!.copyWith(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          excerpt: _excerptController.text.trim().isEmpty
              ? null
              : _excerptController.text.trim(),
          category: _selectedCategory,
          slug: _generateSlug(_titleController.text.trim()),
          published: _isPublished,
        );
        await PostService.updatePost(updatedPost);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Post updated successfully!'),
              backgroundColor: Colors.green),
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        final post = PostModel(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          excerpt: _excerptController.text.trim().isEmpty
              ? null
              : _excerptController.text.trim(),
          category: _selectedCategory,
          slug: _generateSlug(_titleController.text.trim()),
          published: _isPublished,
        );
        await PostService.createPost(post);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Post saved successfully!'),
              backgroundColor: Colors.green),
        );
        _titleController.clear();
        _contentController.clear();
        _excerptController.clear();
        setState(() {
          _isPublished = false;
          _selectedCategory = PostCategory.mentalHealth;
        });
      }

      widget.onPostCreated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error saving post: $e'),
            backgroundColor: Colors.red),
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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isEditing ? 'Edit Post' : 'Write a New Post',
              style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Post Title *',
              border: OutlineInputBorder(),
              hintText: 'Enter your blog post title',
            ),
            maxLines: 2,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<PostCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: PostCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.displayName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
            },
          ),
          SizedBox(height: 16),
          TextField(
            controller: _excerptController,
            decoration: InputDecoration(
              labelText: 'Excerpt (Optional)',
              border: OutlineInputBorder(),
              hintText: 'Brief summary of your post',
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Post Content *',
              border: OutlineInputBorder(),
              hintText: 'Write your blog post content here...',
              alignLabelWithHint: true,
            ),
            maxLines: 15,
            minLines: 10,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isPublished,
                onChanged: (value) {
                  setState(() => _isPublished = value!);
                },
              ),
              Text('Publish immediately'),
              Spacer(),
              Text(_isPublished ? 'Published' : 'Draft',
                  style: TextStyle(
                    color: _isPublished ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _savePost,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(_isEditing ? 'Update Post' : 'Save Post'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    super.dispose();
  }
}
