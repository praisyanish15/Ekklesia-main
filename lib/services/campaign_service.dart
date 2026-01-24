import '../models/campaign_model.dart';
import 'supabase_service.dart';

class CampaignService {
  final _supabase = SupabaseService.client;

  /// Get all donation campaigns for a church
  Future<List<CampaignModel>> getChurchCampaigns(String churchId) async {
    try {
      final response = await _supabase
          .from('donation_campaigns')
          .select()
          .eq('church_id', churchId)
          .order('created_at', ascending: false);

      return List<CampaignModel>.from(
        response.map((campaign) => CampaignModel.fromJson(campaign)),
      );
    } catch (e) {
      throw Exception('Failed to get campaigns: ${e.toString()}');
    }
  }

  /// Get active campaigns only
  Future<List<CampaignModel>> getActiveCampaigns(String churchId) async {
    try {
      final response = await _supabase
          .from('donation_campaigns')
          .select()
          .eq('church_id', churchId)
          .eq('status', 'active')
          .order('end_date', ascending: true);

      return List<CampaignModel>.from(
        response.map((campaign) => CampaignModel.fromJson(campaign)),
      );
    } catch (e) {
      throw Exception('Failed to get active campaigns: ${e.toString()}');
    }
  }

  /// Create a new donation campaign
  Future<CampaignModel> createCampaign({
    required String churchId,
    required String creatorId,
    required String title,
    required String description,
    required double targetAmount,
    required DateTime startDate,
    required DateTime endDate,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase
          .from('donation_campaigns')
          .insert({
            'church_id': churchId,
            'creator_id': creatorId,
            'title': title,
            'description': description,
            'target_amount': targetAmount,
            'current_amount': 0.0,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'image_url': imageUrl,
            'status': 'active',
          })
          .select()
          .single();

      return CampaignModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create campaign: ${e.toString()}');
    }
  }

  /// Update campaign status
  Future<void> updateCampaignStatus({
    required String campaignId,
    required CampaignStatus status,
  }) async {
    try {
      await _supabase
          .from('donation_campaigns')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', campaignId);
    } catch (e) {
      throw Exception('Failed to update campaign: ${e.toString()}');
    }
  }

  /// Delete a campaign
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _supabase
          .from('donation_campaigns')
          .delete()
          .eq('id', campaignId);
    } catch (e) {
      throw Exception('Failed to delete campaign: ${e.toString()}');
    }
  }
}
