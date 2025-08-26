import 'package:uuid/uuid.dart';

enum PostCategory {
  mentalHealth('mental-health'),
  selfHelp('self-help'),
  sliceOfLife('slice-of-life');

  const PostCategory(this.value);
  final String value;

  static PostCategory fromString(String value) {
    return PostCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => PostCategory.mentalHealth,
    );
  }

  String get displayName {
    switch (this) {
      case PostCategory.mentalHealth:
        return 'Mental Health';
      case PostCategory.selfHelp:
        return 'Self Help';
      case PostCategory.sliceOfLife:
        return 'Slice of Life';
    }
  }
}

class PostModel {
  final String id;
  final String title;
  final String content;
  final String? excerpt;
  final PostCategory category;
  final String slug;
  final bool published;
  final String? featuredImageUrl;
  final int likesCount;
  final int viewsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    String? id,
    required this.title,
    required this.content,
    this.excerpt,
    required this.category,
    required this.slug,
    this.published = false,
    this.featuredImageUrl,
    this.likesCount = 0,
    this.viewsCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'],
      category: PostCategory.fromString(json['category']),
      slug: json['slug'],
      published: json['published'] ?? false,
      featuredImageUrl: json['featured_image_url'],
      likesCount: json['likes_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'category': category.value,
      'slug': slug,
      'published': published,
      'featured_image_url': featuredImageUrl,
      'likes_count': likesCount,
      'views_count': viewsCount,
    };
  }

  PostModel copyWith({
    String? title,
    String? content,
    String? excerpt,
    PostCategory? category,
    String? slug,
    bool? published,
    String? featuredImageUrl,
    int? likesCount,
    int? viewsCount,
  }) {
    return PostModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      category: category ?? this.category,
      slug: slug ?? this.slug,
      published: published ?? this.published,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
