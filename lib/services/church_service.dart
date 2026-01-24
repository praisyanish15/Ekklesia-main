import 'dart:math';
import '../models/church_model.dart';
import 'supabase_service.dart';

class ChurchService {
  final _supabase = SupabaseService.client;

  /// Generate a unique 6-character referral code
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Check if church name already exists
  Future<bool> isChurchNameUnique(String name) async {
    try {
      final response = await _supabase
          .from('churches')
          .select('id')
          .ilike('name', name)
          .limit(1);

      return response.isEmpty;
    } catch (e) {
      throw Exception('Failed to check church name: ${e.toString()}');
    }
  }

  /// Check if license number already exists
  Future<bool> isLicenseNumberUnique(String licenseNumber) async {
    try {
      final response = await _supabase
          .from('churches')
          .select('id')
          .eq('license_number', licenseNumber.trim().toUpperCase())
          .limit(1);

      return response.isEmpty;
    } catch (e) {
      throw Exception('Failed to check license number: ${e.toString()}');
    }
  }

  /// Validate license number format (customize based on your requirements)
  bool isValidLicenseNumber(String licenseNumber) {
    // Example: License should be alphanumeric, 8-20 characters
    final regex = RegExp(r'^[A-Z0-9]{8,20}$');
    return regex.hasMatch(licenseNumber.trim().toUpperCase());
  }

  /// Create a new church organization
  Future<ChurchModel> createChurch({
    required String name,
    required String pastorName,
    required String licenseNumber,
    required String area,
    String? address,
    String? city,
    String? state,
    String? country,
    String? phoneNumber,
    String? email,
    String? description,
    String? photoUrl,
    required String createdBy,
    String theme = 'spiritual_blue',
  }) async {
    try {
      // Validate license number format
      if (!isValidLicenseNumber(licenseNumber)) {
        throw Exception(
            'Invalid license number format. Must be 8-20 alphanumeric characters.');
      }

      // Check if church name is unique
      final isNameUnique = await isChurchNameUnique(name);
      if (!isNameUnique) {
        throw Exception(
            'A church with this name already exists. Please choose a different name.');
      }

      // Check if license number is unique
      final isLicenseUnique = await isLicenseNumberUnique(licenseNumber);
      if (!isLicenseUnique) {
        throw Exception(
            'This license number is already registered. Each church must have a unique license number.');
      }

      // Generate unique referral code
      String referralCode;
      bool isReferralUnique = false;
      int attempts = 0;

      do {
        referralCode = _generateReferralCode();
        final response = await _supabase
            .from('churches')
            .select('id')
            .eq('referral_code', referralCode)
            .limit(1);

        isReferralUnique = response.isEmpty;
        attempts++;

        if (attempts > 10) {
          throw Exception('Failed to generate unique referral code');
        }
      } while (!isReferralUnique);

      // Create church
      final churchData = {
        'name': name.trim(),
        'pastor_name': pastorName.trim(),
        'license_number': licenseNumber.trim().toUpperCase(),
        'referral_code': referralCode,
        'area': area.trim(),
        'address': address?.trim(),
        'city': city?.trim(),
        'state': state?.trim(),
        'country': country?.trim(),
        'phone_number': phoneNumber?.trim(),
        'email': email?.trim(),
        'description': description?.trim(),
        'photo_url': photoUrl,
        'created_by': createdBy,
        'theme': theme,
      };

      final response = await _supabase
          .from('churches')
          .insert(churchData)
          .select()
          .single();

      // Automatically add creator as super_admin
      await _supabase.from('church_members').insert({
        'church_id': response['id'],
        'user_id': createdBy,
        'role': 'super_admin',
        'approved_by': createdBy,
        'approved_at': DateTime.now().toIso8601String(),
      });

      return ChurchModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create church: ${e.toString()}');
    }
  }

  /// Join church using referral code
  Future<bool> joinChurchWithReferralCode({
    required String referralCode,
    required String userId,
    bool autoApprove = true, // Auto-approve by default for simpler UX
  }) async {
    try {
      // Find church by referral code
      final churchResponse = await _supabase
          .from('churches')
          .select('id, created_by')
          .eq('referral_code', referralCode.trim().toUpperCase())
          .limit(1);

      if (churchResponse.isEmpty) {
        throw Exception(
            'Invalid referral code. Please check and try again.');
      }

      final churchId = churchResponse.first['id'];
      final createdBy = churchResponse.first['created_by'];

      // Check if user is already a member
      final existingMembership = await _supabase
          .from('church_members')
          .select('id, role')
          .eq('church_id', churchId)
          .eq('user_id', userId)
          .limit(1);

      if (existingMembership.isNotEmpty) {
        // User is already a member - this is OK if they're the creator
        // Just return success since they're already in
        return true;
      }

      // Determine role: church creator gets super_admin, others get member (auto-approved)
      String role;
      if (userId == createdBy) {
        role = 'super_admin';
      } else if (autoApprove) {
        role = 'member'; // Auto-approved as regular member
      } else {
        role = 'pending'; // Needs admin approval
      }

      // Add user to church
      final memberData = {
        'church_id': churchId,
        'user_id': userId,
        'role': role,
      };

      // If auto-approved, add approval details
      if (role != 'pending') {
        memberData['approved_by'] = createdBy;
        memberData['approved_at'] = DateTime.now().toIso8601String();
      }

      await _supabase.from('church_members').insert(memberData);

      return true;
    } catch (e) {
      throw Exception('Failed to join church: ${e.toString()}');
    }
  }

  /// Approve member and assign role (only super_admin and admin can do this)
  Future<void> approveMember({
    required String churchId,
    required String userId,
    required String role, // 'admin', 'committee', or 'member'
    required String approvedBy,
  }) async {
    try {
      await _supabase
          .from('church_members')
          .update({
            'role': role,
            'approved_by': approvedBy,
            'approved_at': DateTime.now().toIso8601String(),
          })
          .eq('church_id', churchId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to approve member: ${e.toString()}');
    }
  }

  /// Get all church members (including pending)
  Future<List<Map<String, dynamic>>> getChurchMembers(String churchId) async {
    try {
      // First try with profiles join
      try {
        final response = await _supabase
            .from('church_members')
            .select('*, profiles(*)')
            .eq('church_id', churchId)
            .order('joined_at', ascending: false);

        // Flatten the nested profiles data
        return List<Map<String, dynamic>>.from(response.map((member) {
          final profiles = member['profiles'] as Map<String, dynamic>?;
          return {
            'id': member['id'],
            'user_id': member['user_id'],
            'role': member['role'],
            'joined_at': member['joined_at'],
            'name': profiles?['name'] ?? 'Unknown',
            'email': profiles?['email'] ?? '',
            'photo_url': profiles?['photo_url'],
            'address': profiles?['address'] ?? '',
            'phone_number': profiles?['phone_number'],
          };
        }));
      } catch (joinError) {
        // If profiles join fails, try without it
        final response = await _supabase
            .from('church_members')
            .select('*')
            .eq('church_id', churchId)
            .order('joined_at', ascending: false);

        return List<Map<String, dynamic>>.from(response.map((member) {
          return {
            'id': member['id'],
            'user_id': member['user_id'],
            'role': member['role'],
            'joined_at': member['joined_at'],
            'name': 'Member',
            'email': '',
            'photo_url': null,
            'address': '',
            'phone_number': null,
          };
        }));
      }
    } catch (e) {
      throw Exception('Failed to get church members: ${e.toString()}');
    }
  }

  /// Get pending members for approval
  Future<List<Map<String, dynamic>>> getPendingMembers(String churchId) async {
    try {
      final response = await _supabase
          .from('church_members')
          .select('*, profiles(*)')
          .eq('church_id', churchId)
          .eq('role', 'pending')
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get pending members: ${e.toString()}');
    }
  }

  /// Get user role in a specific church
  Future<String?> getUserRoleInChurch({
    required String churchId,
    required String userId,
  }) async {
    try {
      final response = await _supabase
          .from('church_members')
          .select('role')
          .eq('church_id', churchId)
          .eq('user_id', userId)
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      return response.first['role'] as String;
    } catch (e) {
      throw Exception('Failed to get user role: ${e.toString()}');
    }
  }

  /// Get church by referral code
  Future<ChurchModel?> getChurchByReferralCode(String referralCode) async {
    try {
      final response = await _supabase
          .from('churches')
          .select()
          .eq('referral_code', referralCode.trim().toUpperCase())
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      return ChurchModel.fromJson(response.first);
    } catch (e) {
      throw Exception('Failed to get church: ${e.toString()}');
    }
  }

  Future<List<ChurchModel>> searchChurches({
    String? name,
    String? area,
  }) async {
    try {
      var query = _supabase.from('churches').select();

      if (name != null && name.isNotEmpty) {
        query = query.ilike('name', '%${name.trim()}%');
      }

      if (area != null && area.isNotEmpty) {
        query = query.ilike('area', '%${area.trim()}%');
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((church) => ChurchModel.fromJson(church))
          .toList();
    } catch (e) {
      throw Exception('Failed to search churches: ${e.toString()}');
    }
  }

  Future<ChurchModel?> getChurchById(String churchId) async {
    try {
      final response = await _supabase
          .from('churches')
          .select()
          .eq('id', churchId)
          .single();

      return ChurchModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch church: ${e.toString()}');
    }
  }

  Future<List<ChurchModel>> getAllChurches() async {
    try {
      final response = await _supabase
          .from('churches')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((church) => ChurchModel.fromJson(church))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch churches: ${e.toString()}');
    }
  }

  Future<void> joinChurch({
    required String userId,
    required String churchId,
  }) async {
    try {
      // Check if user is already a member
      final existingMembership = await _supabase
          .from('church_members')
          .select('id')
          .eq('church_id', churchId)
          .eq('user_id', userId)
          .limit(1);

      if (existingMembership.isNotEmpty) {
        throw Exception('You are already a member of this church.');
      }

      // Add user to church
      await _supabase.from('church_members').insert({
        'church_id': churchId,
        'user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to join church: ${e.toString()}');
    }
  }

  /// Get user's churches
  Future<List<ChurchModel>> getUserChurches(String userId) async {
    try {
      final response = await _supabase
          .from('church_members')
          .select('church_id, churches(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => ChurchModel.fromJson(item['churches']))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user churches: ${e.toString()}');
    }
  }

  /// Get churches created by user
  Future<List<ChurchModel>> getChurchesCreatedByUser(String userId) async {
    try {
      final response = await _supabase
          .from('churches')
          .select()
          .eq('created_by', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((church) => ChurchModel.fromJson(church))
          .toList();
    } catch (e) {
      throw Exception('Failed to get created churches: ${e.toString()}');
    }
  }
}
