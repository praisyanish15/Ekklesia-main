import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/song_model.dart';
import 'supabase_service.dart';

class SongService {
  final _supabase = SupabaseService.client;

  /// Seed default worship songs for a church from the bundled JSON
  Future<void> seedDefaultSongs(String churchId) async {
    try {
      // Check if church already has songs
      final existingSongs = await getChurchSongs(churchId);
      if (existingSongs.isNotEmpty) {
        return; // Church already has songs, don't seed
      }

      // Load songs from bundled JSON
      final jsonString = await rootBundle.loadString('lib/assets/songs.json');
      final jsonData = json.decode(jsonString);
      final songs = jsonData['songs'] as List;

      // Insert songs in batches
      for (final song in songs) {
        await _supabase.from('songs').insert({
          'church_id': churchId,
          'title': song['title'],
          'lyrics': song['lyrics'] ?? 'Lyrics coming soon...',
          'category': song['category'] ?? 'Worship',
          'chords': (song['chords'] as List?)?.join('\n'),
        });
      }
    } catch (e) {
      // Silently fail - songs are optional
      print('Failed to seed default songs: $e');
    }
  }

  /// Get all songs for a church
  Future<List<Song>> getChurchSongs(String churchId) async {
    try {
      final response = await _supabase
          .from('songs')
          .select()
          .eq('church_id', churchId)
          .order('title', ascending: true);

      return List<Song>.from(
        response.map((song) => Song.fromJson(song)),
      );
    } catch (e) {
      throw Exception('Failed to get songs: ${e.toString()}');
    }
  }

  /// Get songs by category
  Future<List<Song>> getSongsByCategory(String churchId, String category) async {
    try {
      final response = await _supabase
          .from('songs')
          .select()
          .eq('church_id', churchId)
          .eq('category', category)
          .order('title', ascending: true);

      return List<Song>.from(
        response.map((song) => Song.fromJson(song)),
      );
    } catch (e) {
      throw Exception('Failed to get songs by category: ${e.toString()}');
    }
  }

  /// Get a single song by ID
  Future<Song> getSong(String songId) async {
    try {
      final response = await _supabase
          .from('songs')
          .select()
          .eq('id', songId)
          .single();

      return Song.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get song: ${e.toString()}');
    }
  }

  /// Create a new song (admin/super_admin only)
  Future<Song> addSong({
    required String churchId,
    required String title,
    String? artist,
    required String lyrics,
    String? category,
    String? chords,
    String? key,
    String? link,
    String language = 'english',
    double? latitude,
    double? longitude,
    String? location,
  }) async {
    try {
      final response = await _supabase
          .from('songs')
          .insert({
            'church_id': churchId,
            'title': title,
            'artist': artist,
            'lyrics': lyrics,
            'category': category,
            'chords': chords,
            'key': key,
            'link': link,
            'language': language,
            'latitude': latitude,
            'longitude': longitude,
            'location': location,
          })
          .select()
          .single();

      return Song.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create song: ${e.toString()}');
    }
  }

  /// Update a song (admin/super_admin only)
  Future<Song> updateSong({
    required String songId,
    String? title,
    String? artist,
    String? lyrics,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (artist != null) updateData['artist'] = artist;
      if (lyrics != null) updateData['lyrics'] = lyrics;
      if (category != null) updateData['category'] = category;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('songs')
          .update(updateData)
          .eq('id', songId)
          .select()
          .single();

      return Song.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update song: ${e.toString()}');
    }
  }

  /// Delete a song (admin/super_admin only)
  Future<void> deleteSong(String songId) async {
    try {
      await _supabase.from('songs').delete().eq('id', songId);
    } catch (e) {
      throw Exception('Failed to delete song: ${e.toString()}');
    }
  }
}
