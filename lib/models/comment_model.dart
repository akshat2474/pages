import 'package:uuid/uuid.dart';

class CommentModel {
  final String id;
  final String postId;
  final String commenterName;
  final String commentText;
  final bool approved;
  final DateTime createdAt;

  CommentModel({
    String? id,
    required this.postId,
    required this.commenterName,
    required this.commentText,
    this.approved = true,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['post_id'],
      commenterName: json['commenter_name'] ?? 'Anonymous',
      commentText: json['comment_text'],
      approved: json['approved'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'commenter_name': commenterName,
      'comment_text': commentText,
      'approved': approved,
    };
  }
}
