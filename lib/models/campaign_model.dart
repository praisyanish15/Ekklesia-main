class CampaignModel {
  final String id;
  final String churchId;
  final String creatorId;
  final String? prayerRequestId;
  final String title;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final CampaignStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CampaignModel({
    required this.id,
    required this.churchId,
    required this.creatorId,
    this.prayerRequestId,
    required this.title,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.status = CampaignStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      creatorId: json['creator_id'] as String,
      prayerRequestId: json['prayer_request_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      imageUrl: json['image_url'] as String?,
      status: CampaignStatus.values.firstWhere(
        (e) => e.toString() == 'CampaignStatus.${json['status']}',
        orElse: () => CampaignStatus.active,
      ),
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
      'creator_id': creatorId,
      'prayer_request_id': prayerRequestId,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
}

enum CampaignStatus {
  active,
  completed,
  expired,
  cancelled,
}
