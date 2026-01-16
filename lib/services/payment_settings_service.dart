import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bank_details_model.dart';
import '../models/church_model.dart';
import 'supabase_service.dart';

class PaymentSettingsService {
  final _supabase = SupabaseService.client;

  /// Update church payment QR code
  Future<void> updatePaymentQrCode({
    required String churchId,
    required String qrCodeUrl,
  }) async {
    try {
      await _supabase.from('churches').update({
        'payment_qr_code_url': qrCodeUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', churchId);
    } catch (e) {
      throw Exception('Failed to update QR code: ${e.toString()}');
    }
  }

  /// Update church UPI ID
  Future<void> updateUpiId({
    required String churchId,
    required String upiId,
  }) async {
    try {
      await _supabase.from('churches').update({
        'upi_id': upiId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', churchId);
    } catch (e) {
      throw Exception('Failed to update UPI ID: ${e.toString()}');
    }
  }

  /// Update Razorpay key
  Future<void> updateRazorpayKey({
    required String churchId,
    required String razorpayKeyId,
  }) async {
    try {
      await _supabase.from('churches').update({
        'razorpay_key_id': razorpayKeyId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', churchId);
    } catch (e) {
      throw Exception('Failed to update Razorpay key: ${e.toString()}');
    }
  }

  /// Get all bank details for a church
  Future<List<BankDetails>> getChurchBankDetails(String churchId) async {
    try {
      final response = await _supabase
          .from('church_bank_details')
          .select()
          .eq('church_id', churchId)
          .order('is_primary', ascending: false);

      return List<BankDetails>.from(
        response.map((details) => BankDetails.fromJson(details)),
      );
    } catch (e) {
      throw Exception('Failed to get bank details: ${e.toString()}');
    }
  }

  /// Add bank details (super_admin only)
  Future<BankDetails> addBankDetails({
    required String churchId,
    required String bankName,
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    String? branchName,
    String? accountType,
    bool isPrimary = false,
  }) async {
    try {
      // If setting as primary, unset other primary accounts
      if (isPrimary) {
        await _supabase
            .from('church_bank_details')
            .update({'is_primary': false})
            .eq('church_id', churchId);
      }

      final response = await _supabase
          .from('church_bank_details')
          .insert({
            'church_id': churchId,
            'bank_name': bankName,
            'account_holder_name': accountHolderName,
            'account_number': accountNumber,
            'ifsc_code': ifscCode,
            'branch_name': branchName,
            'account_type': accountType,
            'is_primary': isPrimary,
          })
          .select()
          .single();

      return BankDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add bank details: ${e.toString()}');
    }
  }

  /// Update bank details (super_admin only)
  Future<BankDetails> updateBankDetails({
    required String bankDetailsId,
    String? bankName,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? accountType,
    bool? isPrimary,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (bankName != null) updateData['bank_name'] = bankName;
      if (accountHolderName != null) {
        updateData['account_holder_name'] = accountHolderName;
      }
      if (accountNumber != null) updateData['account_number'] = accountNumber;
      if (ifscCode != null) updateData['ifsc_code'] = ifscCode;
      if (branchName != null) updateData['branch_name'] = branchName;
      if (accountType != null) updateData['account_type'] = accountType;
      if (isPrimary != null) updateData['is_primary'] = isPrimary;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('church_bank_details')
          .update(updateData)
          .eq('id', bankDetailsId)
          .select()
          .single();

      return BankDetails.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update bank details: ${e.toString()}');
    }
  }

  /// Delete bank details (super_admin only)
  Future<void> deleteBankDetails(String bankDetailsId) async {
    try {
      await _supabase
          .from('church_bank_details')
          .delete()
          .eq('id', bankDetailsId);
    } catch (e) {
      throw Exception('Failed to delete bank details: ${e.toString()}');
    }
  }

  /// Upload QR code image to Supabase Storage
  Future<String> uploadQrCodeImage({
    required String churchId,
    required List<int> fileBytes,
  }) async {
    try {
      final fileName = 'qr_code_${churchId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final path = 'payment-qr-codes/$fileName';

      await _supabase.storage.from('church-assets').uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage.from('church-assets').getPublicUrl(path);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload QR code: ${e.toString()}');
    }
  }
}
