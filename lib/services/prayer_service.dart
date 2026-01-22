import '../models/prayer_request_model.dart';
import '../models/testimony_model.dart';
import 'supabase_service.dart';

class PrayerService {
  final _supabase = SupabaseService.client;

  /// Submit a new prayer request
  Future<PrayerRequestModel> submitPrayerRequest({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String churchId,
    required String title,
    required String description,
    required PrayerCategory category,
    required PrayerPrivacy privacy,
    bool isUrgent = false,
    bool isAnonymous = false,
  }) async {
    try {
      final prayerData = {
        'user_id': userId,
        'user_name': isAnonymous ? 'Anonymous' : userName,
        'user_photo_url': isAnonymous ? null : userPhotoUrl,
        'church_id': churchId,
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'privacy': privacy.name,
        'status': PrayerStatus.active.name,
        'is_urgent': isUrgent,
        'is_anonymous': isAnonymous,
      };

      final response = await _supabase
          .from('prayer_requests')
          .insert(prayerData)
          .select()
          .single();

      return PrayerRequestModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit prayer request: ${e.toString()}');
    }
  }

  /// Get public prayer requests
  Future<List<PrayerRequestModel>> getPublicPrayers({
    required String churchId,
    PrayerCategory? category,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('prayer_requests')
          .select()
          .eq('church_id', churchId)
          .eq('privacy', PrayerPrivacy.public.name)
          .eq('status', PrayerStatus.active.name);

      if (category != null) {
        query = query.eq('category', category.name);
      }

      final response = await query
          .order('is_urgent', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get public prayers: ${e.toString()}');
    }
  }

  /// Get private prayers (only for requester and leadership)
  Future<List<PrayerRequestModel>> getPrivatePrayers({
    required String churchId,
    required String userId,
    required bool isLeadership,
  }) async {
    try {
      var query = _supabase
          .from('prayer_requests')
          .select()
          .eq('church_id', churchId)
          .eq('privacy', PrayerPrivacy.private.name)
          .eq('status', PrayerStatus.active.name);

      // If not leadership, only show user's own private prayers
      if (!isLeadership) {
        query = query.eq('user_id', userId);
      }

      final response = await query
          .order('is_urgent', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get private prayers: ${e.toString()}');
    }
  }

  /// Get leadership-only prayers
  Future<List<PrayerRequestModel>> getLeadershipPrayers({
    required String churchId,
  }) async {
    try {
      final response = await _supabase
          .from('prayer_requests')
          .select()
          .eq('church_id', churchId)
          .eq('privacy', PrayerPrivacy.leadership.name)
          .eq('status', PrayerStatus.active.name)
          .order('is_urgent', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get leadership prayers: ${e.toString()}');
    }
  }

  /// Get user's prayer requests
  Future<List<PrayerRequestModel>> getUserPrayers(String userId) async {
    try {
      final response = await _supabase
          .from('prayer_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user prayers: ${e.toString()}');
    }
  }

  /// Get answered prayers
  Future<List<PrayerRequestModel>> getAnsweredPrayers({
    required String churchId,
    int limit = 20,
  }) async {
    try {
      final response = await _supabase
          .from('prayer_requests')
          .select()
          .eq('church_id', churchId)
          .eq('status', PrayerStatus.answered.name)
          .not('privacy', 'eq', PrayerPrivacy.leadership.name)
          .order('answered_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get answered prayers: ${e.toString()}');
    }
  }

  /// Increment prayer count (when someone says "I prayed")
  Future<void> incrementPrayerCount(String prayerId) async {
    try {
      await _supabase.rpc('increment_prayer_count', params: {
        'prayer_id': prayerId,
      });
    } catch (e) {
      // Silently fail - prayer count is not critical
    }
  }

  /// Mark prayer as answered
  Future<void> markAsAnswered({
    required String prayerId,
    required String testimony,
  }) async {
    try {
      await _supabase.from('prayer_requests').update({
        'status': PrayerStatus.answered.name,
        'answered_testimony': testimony.trim(),
        'answered_at': DateTime.now().toIso8601String(),
      }).eq('id', prayerId);
    } catch (e) {
      throw Exception('Failed to mark prayer as answered: ${e.toString()}');
    }
  }

  /// Convert answered prayer to testimony
  Future<TestimonyModel> convertToTestimony({
    required String prayerId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String churchId,
  }) async {
    try {
      // Get the prayer request
      final prayerResponse = await _supabase
          .from('prayer_requests')
          .select()
          .eq('id', prayerId)
          .single();

      final prayer = PrayerRequestModel.fromJson(prayerResponse);

      if (prayer.status != PrayerStatus.answered ||
          prayer.answeredTestimony == null) {
        throw Exception(
            'Prayer must be marked as answered before converting to testimony');
      }

      // Map prayer category to testimony category
      TestimonyCategory testimonyCategory;
      switch (prayer.category) {
        case PrayerCategory.health:
          testimonyCategory = TestimonyCategory.healing;
          break;
        case PrayerCategory.financial:
          testimonyCategory = TestimonyCategory.financialBreakthrough;
          break;
        case PrayerCategory.family:
        case PrayerCategory.general:
        case PrayerCategory.spiritual:
        case PrayerCategory.other:
          testimonyCategory = TestimonyCategory.answeredPrayer;
          break;
      }

      // Create testimony
      final testimonyData = {
        'user_id': userId,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
        'church_id': churchId,
        'title': 'Answered Prayer: ${prayer.title}',
        'content': prayer.answeredTestimony!,
        'category': testimonyCategory.name,
        'type': TestimonyType.text.name,
        'status': TestimonyStatus.pending.name,
      };

      final testimonyResponse = await _supabase
          .from('testimonies')
          .insert(testimonyData)
          .select()
          .single();

      return TestimonyModel.fromJson(testimonyResponse);
    } catch (e) {
      throw Exception('Failed to convert to testimony: ${e.toString()}');
    }
  }

  /// Archive prayer
  Future<void> archivePrayer(String prayerId) async {
    try {
      await _supabase.from('prayer_requests').update({
        'status': PrayerStatus.archived.name,
      }).eq('id', prayerId);
    } catch (e) {
      throw Exception('Failed to archive prayer: ${e.toString()}');
    }
  }

  /// Update prayer request
  Future<void> updatePrayer({
    required String prayerId,
    String? title,
    String? description,
    PrayerCategory? category,
    PrayerPrivacy? privacy,
    bool? isUrgent,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title.trim();
      if (description != null) updateData['description'] = description.trim();
      if (category != null) updateData['category'] = category.name;
      if (privacy != null) updateData['privacy'] = privacy.name;
      if (isUrgent != null) updateData['is_urgent'] = isUrgent;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('prayer_requests')
          .update(updateData)
          .eq('id', prayerId);
    } catch (e) {
      throw Exception('Failed to update prayer: ${e.toString()}');
    }
  }

  /// Delete prayer request
  Future<void> deletePrayer(String prayerId) async {
    try {
      await _supabase
          .from('prayer_requests')
          .delete()
          .eq('id', prayerId);
    } catch (e) {
      throw Exception('Failed to delete prayer: ${e.toString()}');
    }
  }

  /// Search prayers
  Future<List<PrayerRequestModel>> searchPrayers({
    required String churchId,
    required String query,
    required String userId,
    required bool isLeadership,
  }) async {
    try {
      var dbQuery = _supabase
          .from('prayer_requests')
          .select()
          .eq('church_id', churchId)
          .eq('status', PrayerStatus.active.name)
          .or('title.ilike.%$query%,description.ilike.%$query%');

      // Filter based on user permissions
      if (!isLeadership) {
        dbQuery = dbQuery.or(
          'privacy.eq.${PrayerPrivacy.public.name},and(privacy.eq.${PrayerPrivacy.private.name},user_id.eq.$userId)',
        );
      }

      final response =
          await dbQuery.order('created_at', ascending: false).limit(50);

      return (response as List)
          .map((json) => PrayerRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search prayers: ${e.toString()}');
    }
  }

  /// Get prayer statistics for insights
  Future<Map<String, dynamic>> getPrayerStats(String churchId) async {
    try {
      final activePrayers = await _supabase
          .from('prayer_requests')
          .select('id')
          .eq('church_id', churchId)
          .eq('status', PrayerStatus.active.name);

      final answeredPrayers = await _supabase
          .from('prayer_requests')
          .select('id')
          .eq('church_id', churchId)
          .eq('status', PrayerStatus.answered.name);

      final categoryBreakdown = await _supabase
          .from('prayer_requests')
          .select('category')
          .eq('church_id', churchId)
          .eq('status', PrayerStatus.active.name);

      // Count by category
      final categoryCounts = <String, int>{};
      for (var item in categoryBreakdown) {
        final category = item['category'] as String;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      return {
        'active_count': activePrayers.length,
        'answered_count': answeredPrayers.length,
        'category_breakdown': categoryCounts,
      };
    } catch (e) {
      throw Exception('Failed to get prayer stats: ${e.toString()}');
    }
  }
}
