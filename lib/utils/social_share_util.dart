import 'package:share_plus/share_plus.dart';
import '../models/post_model.dart';

class SocialShareUtil {
  static Future<void> sharePost(PostModel post) async {
    final String content = '''
${post.title}

${_getExcerpt(post)}...

Read more at MindJourney Blog

#MentalHealth #SelfHelp #Wellbeing #MindJourney
    ''';

    try {
      await Share.share(
        content,
        subject: post.title,
      );
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  static Future<void> sharePostWithCategory(PostModel post) async {
    final categoryTag = _getCategoryHashtag(post.category);
    final String content = '''
${post.title}

${_getExcerpt(post)}...

Category: ${post.category.displayName}

Read more at MindJourney Blog

#MentalHealth #SelfHelp #Wellbeing $categoryTag
    ''';

    try {
      await Share.share(
        content,
        subject: '${post.category.displayName}: ${post.title}',
      );
    } catch (e) {
      print('Error sharing with category: $e');
      await sharePost(post);
    }
  }

  static String _getExcerpt(PostModel post) {
    if (post.excerpt != null && post.excerpt!.isNotEmpty) {
      return post.excerpt!;
    }
    
    final cleanContent = post.content
        .replaceAll(RegExp(r'[#*`_~\[\](){}]'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
    
    if (cleanContent.length <= 150) {
      return cleanContent;
    }
    
    return cleanContent.substring(0, 150);
  }

  static String _getCategoryHashtag(PostCategory category) {
    switch (category) {
      case PostCategory.mentalHealth:
        return '#MentalHealthAwareness';
      case PostCategory.selfHelp:
        return '#SelfImprovement';
      case PostCategory.sliceOfLife:
        return '#SliceOfLife';
    }
  }
}
