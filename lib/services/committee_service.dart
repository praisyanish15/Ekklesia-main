import '../models/committee_member_model.dart';
import 'supabase_service.dart';

class CommitteeService {
  final _supabase = SupabaseService.client;

  /// Get all committee members for a church
  Future<List<CommitteeMember>> getCommitteeMembers(String churchId) async {
    try {
      final response = await _supabase
          .from('committee_members')
          .select('*, profiles(*)')
          .eq('church_id', churchId)
          .order('appointed_at', ascending: false);

      return List<CommitteeMember>.from(
        response.map((member) => CommitteeMember.fromJson(member)),
      );
    } catch (e) {
      throw Exception('Failed to get committee members: ${e.toString()}');
    }
  }

  /// Get committee members sorted by position
  Future<Map<String, List<CommitteeMember>>> getCommitteeMembersByPosition(
      String churchId) async {
    try {
      final members = await getCommitteeMembers(churchId);

      final Map<String, List<CommitteeMember>> grouped = {
        'president': [],
        'secretary': [],
        'treasurer': [],
        'member': [],
      };

      for (var member in members) {
        final position = member.position.toLowerCase();
        if (grouped.containsKey(position)) {
          grouped[position]!.add(member);
        }
      }

      return grouped;
    } catch (e) {
      throw Exception('Failed to group committee members: ${e.toString()}');
    }
  }

  /// Add a committee member (super_admin only)
  Future<CommitteeMember> addCommitteeMember({
    required String churchId,
    required String userId,
    required String position,
  }) async {
    try {
      final response = await _supabase
          .from('committee_members')
          .insert({
            'church_id': churchId,
            'user_id': userId,
            'position': position.toLowerCase(),
          })
          .select('*, profiles(*)')
          .single();

      return CommitteeMember.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add committee member: ${e.toString()}');
    }
  }

  /// Update committee member position (super_admin only)
  Future<CommitteeMember> updateCommitteeMemberPosition({
    required String committeeMemberId,
    required String newPosition,
  }) async {
    try {
      final response = await _supabase
          .from('committee_members')
          .update({'position': newPosition.toLowerCase()})
          .eq('id', committeeMemberId)
          .select('*, profiles(*)')
          .single();

      return CommitteeMember.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update committee member: ${e.toString()}');
    }
  }

  /// Remove a committee member (super_admin only)
  Future<void> removeCommitteeMember(String committeeMemberId) async {
    try {
      await _supabase
          .from('committee_members')
          .delete()
          .eq('id', committeeMemberId);
    } catch (e) {
      throw Exception('Failed to remove committee member: ${e.toString()}');
    }
  }
}
