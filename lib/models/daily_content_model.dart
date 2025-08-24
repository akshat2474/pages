class DailyContentModel {
  final DateTime date;
  final String? wordOfDay;
  final String? wordDefinition;
  final String? thoughtOfDay;
  final DateTime createdAt;

  DailyContentModel({
    DateTime? date,
    this.wordOfDay,
    this.wordDefinition,
    this.thoughtOfDay,
    DateTime? createdAt,
  }) : date = date ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  factory DailyContentModel.fromJson(Map<String, dynamic> json) {
    return DailyContentModel(
      date: DateTime.parse(json['date']),
      wordOfDay: json['word_of_day'],
      wordDefinition: json['word_definition'],
      thoughtOfDay: json['thought_of_day'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'word_of_day': wordOfDay,
      'word_definition': wordDefinition,
      'thought_of_day': thoughtOfDay,
    };
  }

  DailyContentModel copyWith({
    DateTime? date,
    String? wordOfDay,
    String? wordDefinition,
    String? thoughtOfDay,
  }) {
    return DailyContentModel(
      date: date ?? this.date,
      wordOfDay: wordOfDay ?? this.wordOfDay,
      wordDefinition: wordDefinition ?? this.wordDefinition,
      thoughtOfDay: thoughtOfDay ?? this.thoughtOfDay,
      createdAt: createdAt,
    );
  }
}
