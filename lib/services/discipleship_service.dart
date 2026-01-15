import '../models/discipleship_path_model.dart';
import 'supabase_service.dart';

class DiscipleshipService {
  final _supabase = SupabaseService.client;

  /// Get all available paths
  Future<List<DiscipleshipPathModel>> getAllPaths() async {
    try {
      final response = await _supabase
          .from('discipleship_paths')
          .select()
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => DiscipleshipPathModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get paths: ${e.toString()}');
    }
  }

  /// Get path by type
  Future<DiscipleshipPathModel?> getPathByType(PathType type) async {
    try {
      final response = await _supabase
          .from('discipleship_paths')
          .select()
          .eq('type', type.name)
          .limit(1);

      if (response.isEmpty) return null;

      return DiscipleshipPathModel.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to get path: ${e.toString()}');
    }
  }

  /// Get weekly steps for a path
  Future<List<WeeklyStepModel>> getWeeklySteps(String pathId) async {
    try {
      final response = await _supabase
          .from('weekly_steps')
          .select()
          .eq('path_id', pathId)
          .order('week_number', ascending: true);

      return (response as List)
          .map((json) => WeeklyStepModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get weekly steps: ${e.toString()}');
    }
  }

  /// Get specific week's step
  Future<WeeklyStepModel?> getWeekStep(String pathId, int weekNumber) async {
    try {
      final response = await _supabase
          .from('weekly_steps')
          .select()
          .eq('path_id', pathId)
          .eq('week_number', weekNumber)
          .limit(1);

      if (response.isEmpty) return null;

      return WeeklyStepModel.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to get week step: ${e.toString()}');
    }
  }

  /// Start a path for user
  Future<UserProgressModel> startPath({
    required String userId,
    required String pathId,
  }) async {
    try {
      // Check if user already has progress on this path
      final existing = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('path_id', pathId)
          .limit(1);

      if (existing.isNotEmpty) {
        return UserProgressModel.fromJson(existing.first);
      }

      // Create new progress
      final response = await _supabase
          .from('user_progress')
          .insert({
            'user_id': userId,
            'path_id': pathId,
            'current_week': 1,
            'started_at': DateTime.now().toIso8601String(),
            'last_accessed_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return UserProgressModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to start path: ${e.toString()}');
    }
  }

  /// Get user's current progress on a path
  Future<UserProgressModel?> getUserProgress({
    required String userId,
    required String pathId,
  }) async {
    try {
      final response = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('path_id', pathId)
          .limit(1);

      if (response.isEmpty) return null;

      return UserProgressModel.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to get user progress: ${e.toString()}');
    }
  }

  /// Get all user's active paths
  Future<List<UserProgressModel>> getUserActivePaths(String userId) async {
    try {
      final response = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('last_accessed_at', ascending: false);

      return (response as List)
          .map((json) => UserProgressModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active paths: ${e.toString()}');
    }
  }

  /// Update user progress (complete current week, move to next)
  Future<void> completeWeek({
    required String userId,
    required String pathId,
    required int currentWeek,
    required int totalWeeks,
  }) async {
    try {
      final isLastWeek = currentWeek >= totalWeeks;

      await _supabase.from('user_progress').update({
        'current_week': isLastWeek ? currentWeek : currentWeek + 1,
        'is_completed': isLastWeek,
        'completed_at': isLastWeek ? DateTime.now().toIso8601String() : null,
        'last_accessed_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('path_id', pathId);
    } catch (e) {
      throw Exception('Failed to complete week: ${e.toString()}');
    }
  }

  /// Update last accessed time
  Future<void> updateLastAccessed({
    required String userId,
    required String pathId,
  }) async {
    try {
      await _supabase.from('user_progress').update({
        'last_accessed_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('path_id', pathId);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Get verse of the day (based on current week of active path)
  Future<Map<String, String>?> getVerseOfTheDay(String userId) async {
    try {
      // Get user's most recent active path
      final activePaths = await getUserActivePaths(userId);
      if (activePaths.isEmpty) return null;

      final progress = activePaths.first;

      // Get current week's step
      final step = await getWeekStep(progress.pathId, progress.currentWeek);
      if (step == null) return null;

      return {
        'verse': step.verse,
        'reference': step.verseReference,
      };
    } catch (e) {
      return null;
    }
  }

  /// Get next step for user
  Future<Map<String, dynamic>?> getNextStep(String userId) async {
    try {
      final activePaths = await getUserActivePaths(userId);
      if (activePaths.isEmpty) return null;

      final progress = activePaths.first;

      // Get path details
      final pathResponse = await _supabase
          .from('discipleship_paths')
          .select()
          .eq('id', progress.pathId)
          .single();

      final path = DiscipleshipPathModel.fromJson(pathResponse);

      // Get current week's step
      final step = await getWeekStep(progress.pathId, progress.currentWeek);
      if (step == null) return null;

      return {
        'path': path,
        'progress': progress,
        'step': step,
      };
    } catch (e) {
      return null;
    }
  }
}
