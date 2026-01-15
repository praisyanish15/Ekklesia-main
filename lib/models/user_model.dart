class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final int? age;
  final String? address;
  final String? gender;
  final String? phoneNumber;
  final UserRole role;
  final String? churchId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.age,
    this.address,
    this.gender,
    this.phoneNumber,
    this.role = UserRole.member,
    this.churchId,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      age: json['age'] as int?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      phoneNumber: json['phone_number'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.member,
      ),
      churchId: json['church_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'age': age,
      'address': address,
      'gender': gender,
      'phone_number': phoneNumber,
      'role': role.name,
      'church_id': churchId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    int? age,
    String? address,
    String? gender,
    String? phoneNumber,
    UserRole? role,
    String? churchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      churchId: churchId ?? this.churchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum UserRole {
  member,
  commander,
  admin,
}
