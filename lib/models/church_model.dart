class ChurchModel {
  final String id;
  final String name;
  final String area;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? description;
  final String? photoUrl;
  final String? pastorName;
  final String licenseNumber;
  final String referralCode;
  final String? createdBy;
  final String theme;
  final double? latitude;
  final double? longitude;
  final String? paymentQrCodeUrl;
  final String? upiId;
  final String? razorpayKeyId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChurchModel({
    required this.id,
    required this.name,
    required this.area,
    this.address,
    this.city,
    this.state,
    this.country,
    this.phoneNumber,
    this.email,
    this.description,
    this.photoUrl,
    this.pastorName,
    required this.licenseNumber,
    required this.referralCode,
    this.createdBy,
    this.theme = 'spiritual_blue',
    this.latitude,
    this.longitude,
    this.paymentQrCodeUrl,
    this.upiId,
    this.razorpayKeyId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChurchModel.fromJson(Map<String, dynamic> json) {
    return ChurchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      area: json['area'] as String,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      photoUrl: json['photo_url'] as String?,
      pastorName: json['pastor_name'] as String?,
      licenseNumber: json['license_number'] as String,
      referralCode: json['referral_code'] as String,
      createdBy: json['created_by'] as String?,
      theme: json['theme'] as String? ?? 'spiritual_blue',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      paymentQrCodeUrl: json['payment_qr_code_url'] as String?,
      upiId: json['upi_id'] as String?,
      razorpayKeyId: json['razorpay_key_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'phone_number': phoneNumber,
      'email': email,
      'description': description,
      'photo_url': photoUrl,
      'pastor_name': pastorName,
      'license_number': licenseNumber,
      'referral_code': referralCode,
      'created_by': createdBy,
      'theme': theme,
      'latitude': latitude,
      'longitude': longitude,
      'payment_qr_code_url': paymentQrCodeUrl,
      'upi_id': upiId,
      'razorpay_key_id': razorpayKeyId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
