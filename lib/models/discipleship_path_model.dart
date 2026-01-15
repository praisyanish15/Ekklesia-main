class DiscipleshipPathModel {
  final String id;
  final String name;
  final String description;
  final PathType type;
  final int durationWeeks;
  final String? iconUrl;
  final DateTime createdAt;

  DiscipleshipPathModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationWeeks,
    this.iconUrl,
    required this.createdAt,
  });

  factory DiscipleshipPathModel.fromJson(Map<String, dynamic> json) {
    return DiscipleshipPathModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: PathType.values.firstWhere(
        (e) => e.toString() == 'PathType.${json['type']}',
        orElse: () => PathType.newBeliever,
      ),
      durationWeeks: json['duration_weeks'] as int,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'duration_weeks': durationWeeks,
      'icon_url': iconUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get typeDisplay {
    switch (type) {
      case PathType.newBeliever:
        return 'New Believer';
      case PathType.youth:
        return 'Youth Growth';
      case PathType.prayerFasting:
        return 'Prayer & Fasting';
      case PathType.leadership:
        return 'Leadership';
      case PathType.marriage:
        return 'Marriage';
      case PathType.parenting:
        return 'Parenting';
    }
  }
}

class WeeklyStepModel {
  final String id;
  final String pathId;
  final int weekNumber;
  final String title;
  final String verse;
  final String verseReference;
  final String devotion;
  final String reflectionQuestion;
  final String actionStep;
  final DateTime createdAt;

  WeeklyStepModel({
    required this.id,
    required this.pathId,
    required this.weekNumber,
    required this.title,
    required this.verse,
    required this.verseReference,
    required this.devotion,
    required this.reflectionQuestion,
    required this.actionStep,
    required this.createdAt,
  });

  factory WeeklyStepModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStepModel(
      id: json['id'] as String,
      pathId: json['path_id'] as String,
      weekNumber: json['week_number'] as int,
      title: json['title'] as String,
      verse: json['verse'] as String,
      verseReference: json['verse_reference'] as String,
      devotion: json['devotion'] as String,
      reflectionQuestion: json['reflection_question'] as String,
      actionStep: json['action_step'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path_id': pathId,
      'week_number': weekNumber,
      'title': title,
      'verse': verse,
      'verse_reference': verseReference,
      'devotion': devotion,
      'reflection_question': reflectionQuestion,
      'action_step': actionStep,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserProgressModel {
  final String id;
  final String userId;
  final String pathId;
  final int currentWeek;
  final bool isCompleted;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? lastAccessedAt;

  UserProgressModel({
    required this.id,
    required this.userId,
    required this.pathId,
    required this.currentWeek,
    this.isCompleted = false,
    required this.startedAt,
    this.completedAt,
    this.lastAccessedAt,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pathId: json['path_id'] as String,
      currentWeek: json['current_week'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'path_id': pathId,
      'current_week': currentWeek,
      'is_completed': isCompleted,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
    };
  }

  UserProgressModel copyWith({
    String? id,
    String? userId,
    String? pathId,
    int? currentWeek,
    bool? isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastAccessedAt,
  }) {
    return UserProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pathId: pathId ?? this.pathId,
      currentWeek: currentWeek ?? this.currentWeek,
      isCompleted: isCompleted ?? this.isCompleted,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}

enum PathType {
  newBeliever,
  youth,
  prayerFasting,
  leadership,
  marriage,
  parenting,
}
