class ReadingTimeUtil {
  static const int averageWordsPerMinute = 200;

  static String calculateReadingTime(
    String content, {
    int wordsPerMinute = averageWordsPerMinute,
  }) {
    if (content.isEmpty) return '0 min read';

    final wordCount = getWordCount(content);
    final minutes = (wordCount / wordsPerMinute).ceil();

    if (minutes < 1) {
      return 'Less than 1 min read';
    } else if (minutes == 1) {
      return '1 min read';
    } else {
      return '$minutes min read';
    }
  }

  static int getWordCount(String content) {
    if (content.isEmpty) return 0;
    final cleanContent = content
        .replaceAll(RegExp(r'[#*`_~\[\](){}]'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .trim();

    if (cleanContent.isEmpty) return 0;

    final words = cleanContent.split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }

  static String getReadingStats(String content) {
    final wordCount = getWordCount(content);
    final readingTime = calculateReadingTime(content);

    return '$wordCount words • $readingTime';
  }

  static Duration getReadingDuration(
    String content, {
    int wordsPerMinute = averageWordsPerMinute,
  }) {
    final wordCount = getWordCount(content);
    final minutes = (wordCount / wordsPerMinute).ceil();
    return Duration(minutes: minutes);
  }
}
