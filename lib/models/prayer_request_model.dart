class PrayerRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String churchId;
  final String title;
  final String description;
  final PrayerCategory category;
  final PrayerPrivacy privacy;
  final PrayerStatus status;
  final bool isUrgent;
  final bool isAnonymous;
  final int prayerCount;
  final String? answeredTestimony;
  final DateTime? answeredAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PrayerRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.churchId,
    required this.title,
    required this.description,
    required this.category,
    this.privacy = PrayerPrivacy.public,
    this.status = PrayerStatus.active,
    this.isUrgent = false,
    this.isAnonymous = false,
    this.prayerCount = 0,
    this.answeredTestimony,
    this.answeredAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) {
    return PrayerRequestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      churchId: json['church_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: PrayerCategory.values.firstWhere(
        (e) => e.toString() == 'PrayerCategory.${json['category']}',
        orElse: () => PrayerCategory.general,
      ),
      privacy: PrayerPrivacy.values.firstWhere(
        (e) => e.toString() == 'PrayerPrivacy.${json['privacy']}',
        orElse: () => PrayerPrivacy.public,
      ),
      status: PrayerStatus.values.firstWhere(
        (e) => e.toString() == 'PrayerStatus.${json['status']}',
        orElse: () => PrayerStatus.active,
      ),
      isUrgent: json['is_urgent'] as bool? ?? false,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      prayerCount: json['prayer_count'] as int? ?? 0,
      answeredTestimony: json['answered_testimony'] as String?,
      answeredAt: json['answered_at'] != null
          ? DateTime.parse(json['answered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'church_id': churchId,
      'title': title,
      'description': description,
      'category': category.name,
      'privacy': privacy.name,
      'status': status.name,
      'is_urgent': isUrgent,
      'is_anonymous': isAnonymous,
      'prayer_count': prayerCount,
      'answered_testimony': answeredTestimony,
      'answered_at': answeredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PrayerRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? churchId,
    String? title,
    String? description,
    PrayerCategory? category,
    PrayerPrivacy? privacy,
    PrayerStatus? status,
    bool? isUrgent,
    bool? isAnonymous,
    int? prayerCount,
    String? answeredTestimony,
    DateTime? answeredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrayerRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      churchId: churchId ?? this.churchId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      privacy: privacy ?? this.privacy,
      status: status ?? this.status,
      isUrgent: isUrgent ?? this.isUrgent,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      prayerCount: prayerCount ?? this.prayerCount,
      answeredTestimony: answeredTestimony ?? this.answeredTestimony,
      answeredAt: answeredAt ?? this.answeredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get categoryDisplay {
    switch (category) {
      case PrayerCategory.general:
        return 'General';
      case PrayerCategory.health:
        return 'Health & Healing';
      case PrayerCategory.family:
        return 'Family';
      case PrayerCategory.financial:
        return 'Financial';
      case PrayerCategory.spiritual:
        return 'Spiritual Growth';
      case PrayerCategory.other:
        return 'Other';
    }
  }

  String get privacyDisplay {
    switch (privacy) {
      case PrayerPrivacy.public:
        return 'Public';
      case PrayerPrivacy.private:
        return 'Private';
      case PrayerPrivacy.leadership:
        return 'Leadership Only';
    }
  }

  String get statusDisplay {
    switch (status) {
      case PrayerStatus.active:
        return 'Active';
      case PrayerStatus.answered:
        return 'Answered';
      case PrayerStatus.archived:
        return 'Archived';
    }
  }
}

enum PrayerCategory {
  general,
  health,
  family,
  financial,
  spiritual,
  other,
}

enum PrayerPrivacy {
  public,    // Everyone can see
  private,   // Only requester and leadership
  leadership, // Only church leadership
}

enum PrayerStatus {
  active,    // Currently being prayed for
  answered,  // Prayer was answered
  archived,  // No longer active
}
