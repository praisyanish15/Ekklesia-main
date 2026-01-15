import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../constants/app_constants.dart';
import 'supabase_service.dart';

class PaymentService {
  late Razorpay _razorpay;
  final _supabase = SupabaseService.client;

  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      onSuccess(response as PaymentSuccessResponse);
    });
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      onFailure(response as PaymentFailureResponse);
    });
  }

  void startPayment({
    required double amount,
    required String campaignId,
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) {
    var options = {
      'key': AppConstants.razorpayKeyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': 'Ekklesia',
      'description': 'Campaign Donation',
      'prefill': {
        'contact': phone ?? '',
        'email': email ?? '',
      },
      'notes': {
        'campaign_id': campaignId,
        'user_id': userId,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      throw Exception('Failed to start payment: ${e.toString()}');
    }
  }

  Future<void> recordDonation({
    required String campaignId,
    required String userId,
    required double amount,
    required String paymentId,
  }) async {
    try {
      // Record donation
      await _supabase.from('donations').insert({
        'campaign_id': campaignId,
        'user_id': userId,
        'amount': amount,
        'payment_id': paymentId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update campaign amount
      final campaign = await _supabase
          .from('campaigns')
          .select('current_amount')
          .eq('id', campaignId)
          .single();

      final newAmount = (campaign['current_amount'] as num).toDouble() + amount;

      await _supabase
          .from('campaigns')
          .update({'current_amount': newAmount}).eq('id', campaignId);
    } catch (e) {
      throw Exception('Failed to record donation: ${e.toString()}');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
