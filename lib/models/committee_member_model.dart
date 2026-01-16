class CommitteeMember {
  final String id;
  final String churchId;
  final String userId;
  final String position; // president, secretary, treasurer, member
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? address;
  final DateTime appointedAt;

  CommitteeMember({
    required this.id,
    required this.churchId,
    required this.userId,
    required this.position,
    required this.name,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.address,
    required this.appointedAt,
  });

  factory CommitteeMember.fromJson(Map<String, dynamic> json) {
    // Handle nested profiles data if present
    final profiles = json['profiles'] as Map<String, dynamic>?;

    return CommitteeMember(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      userId: json['user_id'] as String,
      position: json['position'] as String,
      name: profiles?['name'] ?? json['name'] ?? 'Unknown',
      email: profiles?['email'] ?? json['email'],
      phoneNumber: profiles?['phone_number'] ?? json['phone_number'],
      photoUrl: profiles?['photo_url'] ?? json['photo_url'],
      address: profiles?['address'] ?? json['address'],
      appointedAt: DateTime.parse(json['appointed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'church_id': churchId,
      'user_id': userId,
      'position': position,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'address': address,
      'appointed_at': appointedAt.toIso8601String(),
    };
  }

  String get displayPosition {
    switch (position.toLowerCase()) {
      case 'president':
        return 'President';
      case 'secretary':
        return 'Secretary';
      case 'treasurer':
        return 'Treasurer';
      case 'member':
        return 'Committee Member';
      default:
        return position;
    }
  }
}
