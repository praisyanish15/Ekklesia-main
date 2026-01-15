enum TestimonyCategory {
  healing,
  financialBreakthrough,
  salvation,
  deliverance,
  provision,
  protection,
  answeredPrayer,
  other,
}

enum TestimonyType {
  text,
  audio,
  video,
}

enum TestimonyStatus {
  pending,
  approved,
  rejected,
}

class TestimonyModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String title;
  final String content;
  final TestimonyCategory category;
  final TestimonyType type;
  final TestimonyStatus status;
  final String? audioUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? churchId;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TestimonyModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.title,
    required this.content,
    required this.category,
    required this.type,
    required this.status,
    this.audioUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.churchId,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.isFeatured = false,
    this.viewCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory TestimonyModel.fromJson(Map<String, dynamic> json) {
    return TestimonyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      category: TestimonyCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TestimonyCategory.other,
      ),
      type: TestimonyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TestimonyType.text,
      ),
      status: TestimonyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TestimonyStatus.pending,
      ),
      audioUrl: json['audio_url'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      churchId: json['church_id'] as String?,
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
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
      'title': title,
      'content': content,
      'category': category.name,
      'type': type.name,
      'status': status.name,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'church_id': churchId,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get categoryDisplay {
    switch (category) {
      case TestimonyCategory.healing:
        return 'Healing';
      case TestimonyCategory.financialBreakthrough:
        return 'Financial Breakthrough';
      case TestimonyCategory.salvation:
        return 'Salvation';
      case TestimonyCategory.deliverance:
        return 'Deliverance';
      case TestimonyCategory.provision:
        return 'Provision';
      case TestimonyCategory.protection:
        return 'Protection';
      case TestimonyCategory.answeredPrayer:
        return 'Answered Prayer';
      case TestimonyCategory.other:
        return 'Other';
    }
  }

  TestimonyModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? title,
    String? content,
    TestimonyCategory? category,
    TestimonyType? type,
    TestimonyStatus? status,
    String? audioUrl,
    String? videoUrl,
    String? thumbnailUrl,
    String? churchId,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestimonyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      type: type ?? this.type,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      churchId: churchId ?? this.churchId,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
