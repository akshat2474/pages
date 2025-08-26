class AboutModel {
  final String id;
  final String content;
  final String? profilePictureUrl;

  AboutModel({required this.id, required this.content, this.profilePictureUrl});

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      id: json['id'],
      content: json['content'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'profile_picture_url': profilePictureUrl,
    };
  }
}
