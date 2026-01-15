import 'dart:io';
import '../models/testimony_model.dart';
import 'supabase_service.dart';

class TestimonyService {
  final _supabase = SupabaseService.client;

  /// Submit a new testimony
  Future<TestimonyModel> submitTestimony({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String title,
    required String content,
    required TestimonyCategory category,
    required TestimonyType type,
    String? churchId,
    File? audioFile,
    File? videoFile,
  }) async {
    try {
      String? audioUrl;
      String? videoUrl;
      String? thumbnailUrl;

      // Upload audio file if provided
      if (audioFile != null && type == TestimonyType.audio) {
        final fileName =
            'testimonies/audio/${DateTime.now().millisecondsSinceEpoch}_${userId}.mp3';
        await _supabase.storage.from('testimony-media').upload(
              fileName,
              audioFile,
            );
        audioUrl = _supabase.storage.from('testimony-media').getPublicUrl(fileName);
      }

      // Upload video file if provided
      if (videoFile != null && type == TestimonyType.video) {
        final fileName =
            'testimonies/video/${DateTime.now().millisecondsSinceEpoch}_${userId}.mp4';
        await _supabase.storage.from('testimony-media').upload(
              fileName,
              videoFile,
            );
        videoUrl = _supabase.storage.from('testimony-media').getPublicUrl(fileName);
      }

      final testimonyData = {
        'user_id': userId,
        'user_name': userName,
        'user_photo_url': userPhotoUrl,
        'title': title.trim(),
        'content': content.trim(),
        'category': category.name,
        'type': type.name,
        'status': TestimonyStatus.pending.name,
        'audio_url': audioUrl,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'church_id': churchId,
      };

      final response = await _supabase
          .from('testimonies')
          .insert(testimonyData)
          .select()
          .single();

      return TestimonyModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit testimony: ${e.toString()}');
    }
  }

  /// Get all approved testimonies
  Future<List<TestimonyModel>> getApprovedTestimonies({
    String? churchId,
    TestimonyCategory? category,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('testimonies')
          .select()
          .eq('status', TestimonyStatus.approved.name);

      if (churchId != null) {
        query = query.eq('church_id', churchId);
      }

      if (category != null) {
        query = query.eq('category', category.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TestimonyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get testimonies: ${e.toString()}');
    }
  }

  /// Get featured testimonies
  Future<List<TestimonyModel>> getFeaturedTestimonies({
    String? churchId,
    int limit = 10,
  }) async {
    try {
      var query = _supabase
          .from('testimonies')
          .select()
          .eq('status', TestimonyStatus.approved.name)
          .eq('is_featured', true);

      if (churchId != null) {
        query = query.eq('church_id', churchId);
      }

      final response = await query
          .order('approved_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => TestimonyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured testimonies: ${e.toString()}');
    }
  }

  /// Get pending testimonies (for admins)
  Future<List<TestimonyModel>> getPendingTestimonies({
    String? churchId,
  }) async {
    try {
      var query = _supabase
          .from('testimonies')
          .select()
          .eq('status', TestimonyStatus.pending.name);

      if (churchId != null) {
        query = query.eq('church_id', churchId);
      }

      final response =
          await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => TestimonyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending testimonies: ${e.toString()}');
    }
  }

  /// Get user's testimonies
  Future<List<TestimonyModel>> getUserTestimonies(String userId) async {
    try {
      final response = await _supabase
          .from('testimonies')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TestimonyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user testimonies: ${e.toString()}');
    }
  }

  /// Approve testimony (admin only)
  Future<void> approveTestimony({
    required String testimonyId,
    required String approvedBy,
    bool isFeatured = false,
  }) async {
    try {
      await _supabase.from('testimonies').update({
        'status': TestimonyStatus.approved.name,
        'approved_by': approvedBy,
        'approved_at': DateTime.now().toIso8601String(),
        'is_featured': isFeatured,
      }).eq('id', testimonyId);
    } catch (e) {
      throw Exception('Failed to approve testimony: ${e.toString()}');
    }
  }

  /// Reject testimony (admin only)
  Future<void> rejectTestimony({
    required String testimonyId,
    String? reason,
  }) async {
    try {
      await _supabase.from('testimonies').update({
        'status': TestimonyStatus.rejected.name,
        'rejection_reason': reason,
      }).eq('id', testimonyId);
    } catch (e) {
      throw Exception('Failed to reject testimony: ${e.toString()}');
    }
  }

  /// Toggle featured status
  Future<void> toggleFeatured(String testimonyId, bool isFeatured) async {
    try {
      await _supabase
          .from('testimonies')
          .update({'is_featured': isFeatured}).eq('id', testimonyId);
    } catch (e) {
      throw Exception('Failed to update featured status: ${e.toString()}');
    }
  }

  /// Increment view count
  Future<void> incrementViewCount(String testimonyId) async {
    try {
      await _supabase.rpc('increment_testimony_views', params: {
        'testimony_id': testimonyId,
      });
    } catch (e) {
      // Silently fail - view count is not critical
    }
  }

  /// Like testimony
  Future<void> likeTestimony(String testimonyId, String userId) async {
    try {
      // Check if already liked
      final existing = await _supabase
          .from('testimony_likes')
          .select()
          .eq('testimony_id', testimonyId)
          .eq('user_id', userId)
          .limit(1);

      if (existing.isEmpty) {
        await _supabase.from('testimony_likes').insert({
          'testimony_id': testimonyId,
          'user_id': userId,
        });

        // Increment like count
        await _supabase.rpc('increment_testimony_likes', params: {
          'testimony_id': testimonyId,
        });
      }
    } catch (e) {
      throw Exception('Failed to like testimony: ${e.toString()}');
    }
  }

  /// Unlike testimony
  Future<void> unlikeTestimony(String testimonyId, String userId) async {
    try {
      await _supabase
          .from('testimony_likes')
          .delete()
          .eq('testimony_id', testimonyId)
          .eq('user_id', userId);

      // Decrement like count
      await _supabase.rpc('decrement_testimony_likes', params: {
        'testimony_id': testimonyId,
      });
    } catch (e) {
      throw Exception('Failed to unlike testimony: ${e.toString()}');
    }
  }

  /// Check if user has liked testimony
  Future<bool> hasUserLiked(String testimonyId, String userId) async {
    try {
      final response = await _supabase
          .from('testimony_likes')
          .select()
          .eq('testimony_id', testimonyId)
          .eq('user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Search testimonies
  Future<List<TestimonyModel>> searchTestimonies(String query) async {
    try {
      final response = await _supabase
          .from('testimonies')
          .select()
          .eq('status', TestimonyStatus.approved.name)
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => TestimonyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search testimonies: ${e.toString()}');
    }
  }
}
