import '../models/sermon_model.dart';
import 'supabase_service.dart';

class SermonService {
  final _supabase = SupabaseService.client;

  /// Get all sermons for a church
  Future<List<Sermon>> getChurchSermons(String churchId) async {
    try {
      final response = await _supabase
          .from('sermons')
          .select()
          .eq('church_id', churchId)
          .order('date', ascending: false);

      return List<Sermon>.from(
        response.map((sermon) => Sermon.fromJson(sermon)),
      );
    } catch (e) {
      throw Exception('Failed to get sermons: ${e.toString()}');
    }
  }

  /// Get a single sermon by ID
  Future<Sermon> getSermon(String sermonId) async {
    try {
      final response = await _supabase
          .from('sermons')
          .select()
          .eq('id', sermonId)
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get sermon: ${e.toString()}');
    }
  }

  /// Create a new sermon (admin/super_admin only)
  Future<Sermon> createSermon({
    required String churchId,
    required String title,
    required String pastorName,
    String? description,
    required List<String> keyPoints,
    required List<String> verses,
    required DateTime date,
    String? audioUrl,
    String? videoUrl,
  }) async {
    try {
      final response = await _supabase
          .from('sermons')
          .insert({
            'church_id': churchId,
            'title': title,
            'pastor_name': pastorName,
            'description': description,
            'key_points': keyPoints,
            'verses': verses,
            'date': date.toIso8601String(),
            'audio_url': audioUrl,
            'video_url': videoUrl,
          })
          .select()
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create sermon: ${e.toString()}');
    }
  }

  /// Update a sermon (admin/super_admin only)
  Future<Sermon> updateSermon({
    required String sermonId,
    String? title,
    String? pastorName,
    String? description,
    List<String>? keyPoints,
    List<String>? verses,
    DateTime? date,
    String? audioUrl,
    String? videoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (pastorName != null) updateData['pastor_name'] = pastorName;
      if (description != null) updateData['description'] = description;
      if (keyPoints != null) updateData['key_points'] = keyPoints;
      if (verses != null) updateData['verses'] = verses;
      if (date != null) updateData['date'] = date.toIso8601String();
      if (audioUrl != null) updateData['audio_url'] = audioUrl;
      if (videoUrl != null) updateData['video_url'] = videoUrl;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('sermons')
          .update(updateData)
          .eq('id', sermonId)
          .select()
          .single();

      return Sermon.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update sermon: ${e.toString()}');
    }
  }

  /// Delete a sermon (admin/super_admin only)
  Future<void> deleteSermon(String sermonId) async {
    try {
      await _supabase.from('sermons').delete().eq('id', sermonId);
    } catch (e) {
      throw Exception('Failed to delete sermon: ${e.toString()}');
    }
  }
}
