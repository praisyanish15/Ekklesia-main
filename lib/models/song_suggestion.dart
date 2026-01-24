class SongSuggestion {
  final List<String> bibleVerses;
  final List<String> themes;
  final String? callToWorship;
  final String? prayerPoints;
  final String? benediction;

  SongSuggestion({
    required this.bibleVerses,
    required this.themes,
    this.callToWorship,
    this.prayerPoints,
    this.benediction,
  });

  factory SongSuggestion.fromJson(Map<String, dynamic> json) {
    return SongSuggestion(
      bibleVerses: List<String>.from(json['verses'] ?? []),
      themes: List<String>.from(json['themes'] ?? []),
      callToWorship: json['callToWorship'] as String?,
      prayerPoints: json['prayerPoints'] as String?,
      benediction: json['benediction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verses': bibleVerses,
      'themes': themes,
      'callToWorship': callToWorship,
      'prayerPoints': prayerPoints,
      'benediction': benediction,
    };
  }

  bool get hasContent =>
      bibleVerses.isNotEmpty ||
      themes.isNotEmpty ||
      callToWorship != null ||
      prayerPoints != null ||
      benediction != null;
}

class SongSuggestionMapping {
  final List<String> keywords;
  final SongSuggestion suggestion;

  SongSuggestionMapping({
    required this.keywords,
    required this.suggestion,
  });

  factory SongSuggestionMapping.fromJson(Map<String, dynamic> json) {
    return SongSuggestionMapping(
      keywords: List<String>.from(json['keywords'] ?? []),
      suggestion: SongSuggestion.fromJson(json),
    );
  }

  /// Check if this mapping matches the given text (title or lyrics)
  bool matches(String text) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  /// Calculate a match score (higher = better match)
  int matchScore(String text) {
    final lowerText = text.toLowerCase();
    int score = 0;
    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        score++;
      }
    }
    return score;
  }
}
