class Sermon {
  final String id;
  final String churchId;
  final String title;
  final String pastorName;
  final String? description;
  final List<String> keyPoints;
  final List<String> verses; // Bible verses referenced
  final DateTime date;
  final String? audioUrl;
  final String? videoUrl;
  final DateTime createdAt;

  Sermon({
    required this.id,
    required this.churchId,
    required this.title,
    required this.pastorName,
    this.description,
    required this.keyPoints,
    required this.verses,
    required this.date,
    this.audioUrl,
    this.videoUrl,
    required this.createdAt,
  });

  factory Sermon.fromJson(Map<String, dynamic> json) {
    return Sermon(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      title: json['title'] as String,
      pastorName: json['pastor_name'] as String,
      description: json['description'] as String?,
      keyPoints: List<String>.from(json['key_points'] ?? []),
      verses: List<String>.from(json['verses'] ?? []),
      date: DateTime.parse(json['date'] as String),
      audioUrl: json['audio_url'] as String?,
      videoUrl: json['video_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'church_id': churchId,
      'title': title,
      'pastor_name': pastorName,
      'description': description,
      'key_points': keyPoints,
      'verses': verses,
      'date': date.toIso8601String(),
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
