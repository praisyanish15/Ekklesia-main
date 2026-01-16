class BankDetails {
  final String id;
  final String churchId;
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String? branchName;
  final String? accountType; // savings or current
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BankDetails({
    required this.id,
    required this.churchId,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    this.branchName,
    this.accountType,
    this.isPrimary = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      id: json['id'] as String,
      churchId: json['church_id'] as String,
      bankName: json['bank_name'] as String,
      accountHolderName: json['account_holder_name'] as String,
      accountNumber: json['account_number'] as String,
      ifscCode: json['ifsc_code'] as String,
      branchName: json['branch_name'] as String?,
      accountType: json['account_type'] as String?,
      isPrimary: json['is_primary'] as bool? ?? true,
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
      'bank_name': bankName,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'branch_name': branchName,
      'account_type': accountType,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Get masked account number for display (show last 4 digits)
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '••••${accountNumber.substring(accountNumber.length - 4)}';
  }
}
