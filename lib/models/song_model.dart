class Song {
  final String id;
  final String churchId;
  final String title;
  final String? artist;
  final String lyrics;
  final String? category; // e.g., Worship, Praise, Hymn
  final DateTime createdAt;
  final DateTime? updatedAt;

  Song({
    required this.id,
    required this.churchId,
    required this.title,
    this.artist,
    required this.lyrics,
    this.category,
    required this.createdAt,
    this.updatedAt,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      lyrics: json['lyrics'] as String,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'church_id': churchId,
      'title': title,
      'artist': artist,
      'lyrics': lyrics,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
