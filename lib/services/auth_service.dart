import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    int? age,
    String? address,
    String? gender,
    String? phoneNumber,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // Wait a moment for the trigger to create the profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Create user profile
      final userProfile = {
        'id': response.user!.id,
        'email': email,
        'name': name,
        'age': age,
        'address': address,
        'gender': gender,
        'phone_number': phoneNumber,
        'role': UserRole.member.name,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Update the profile with additional info (trigger creates basic profile)
      final updates = <String, dynamic>{
        'name': name,
      };

      if (age != null) updates['age'] = age;
      if (address != null && address.isNotEmpty) updates['address'] = address;
      if (gender != null) updates['gender'] = gender;
      if (phoneNumber != null && phoneNumber.isNotEmpty) updates['phone_number'] = phoneNumber;

      await _supabase.from('profiles').update(updates).eq('id', response.user!.id);

      return UserModel.fromJson({
        ...userProfile,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on AuthException catch (e) {
      print('AuthException during signup: ${e.message}');
      print('AuthException details: ${e.statusCode}');
      throw Exception('Sign up failed: ${e.message}');
    } on PostgrestException catch (e) {
      print('PostgrestException during signup: ${e.message}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('Unknown error during signup: ${e.toString()}');
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to sign in');
      }

      // Check if email is confirmed (only if confirmation is required)
      if (response.user!.emailConfirmedAt == null) {
        // Sign out the user since they can't proceed
        await _supabase.auth.signOut();
        throw Exception(
          'Email not verified. Please check your email for the verification link. '
          'If you did not receive it, contact your administrator to disable email confirmation in Supabase settings.'
        );
      }

      // Fetch user profile
      final userProfile = await _supabase
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userProfile);
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw Exception(
          'Email not verified. Please verify your email before signing in. '
          'Check your inbox for the verification link.'
        );
      }
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userProfile = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userProfile);
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    int? age,
    String? address,
    String? gender,
    String? phoneNumber,
    String? churchId,
  }) async {
    try {
      final updates = {
        if (name != null) 'name': name,
        if (age != null) 'age': age,
        if (address != null) 'address': address,
        if (gender != null) 'gender': gender,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (churchId != null) 'church_id': churchId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<String?> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final fileName = 'profile_$userId.${imageFile.path.split('.').last}';
      final filePath = 'profiles/$fileName';

      await _supabase.storage.from('profile-photos').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final photoUrl =
          _supabase.storage.from('profile-photos').getPublicUrl(filePath);

      await _supabase
          .from('profiles')
          .update({'photo_url': photoUrl}).eq('id', userId);

      return photoUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: ${e.toString()}');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }
}
