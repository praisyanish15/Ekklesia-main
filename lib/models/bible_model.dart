class BibleVerse {
  final String book;
  final int chapter;
  final int verse;
  final String text;
  final String version;

  BibleVerse({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.version,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      text: json['text'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'version': version,
    };
  }

  String get reference => '$book $chapter:$verse';
}

class BibleBookmark {
  final String id;
  final String userId;
  final String book;
  final int chapter;
  final int verse;
  final String? note;
  final DateTime createdAt;

  BibleBookmark({
    required this.id,
    required this.userId,
    required this.book,
    required this.chapter,
    required this.verse,
    this.note,
    required this.createdAt,
  });

  factory BibleBookmark.fromJson(Map<String, dynamic> json) {
    return BibleBookmark(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get reference => '$book $chapter:$verse';
}

class BibleSettings {
  final String version;
  final double fontSize;
  final bool isDarkMode;

  BibleSettings({
    this.version = 'KJV',
    this.fontSize = 16.0,
    this.isDarkMode = false,
  });

  factory BibleSettings.fromJson(Map<String, dynamic> json) {
    return BibleSettings(
      version: json['version'] as String? ?? 'KJV',
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      isDarkMode: json['is_dark_mode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'font_size': fontSize,
      'is_dark_mode': isDarkMode,
    };
  }

  BibleSettings copyWith({
    String? version,
    double? fontSize,
    bool? isDarkMode,
  }) {
    return BibleSettings(
      version: version ?? this.version,
      fontSize: fontSize ?? this.fontSize,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
