import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bible_model.dart';
import 'supabase_service.dart';

class BibleService {
  final _supabase = SupabaseService.client;

  Future<List<BibleVerse>> fetchVerses({
    required String book,
    required int chapter,
    String version = 'KJV',
  }) async {
    try {
      // Try to fetch from API first
      final url = 'https://bible-api.com/$book+$chapter?translation=$version';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = <BibleVerse>[];

        if (data['verses'] != null) {
          for (var verse in data['verses']) {
            verses.add(BibleVerse(
              book: book,
              chapter: chapter,
              verse: verse['verse'] as int,
              text: verse['text'] as String,
              version: version,
            ));
          }
        }

        return verses;
      } else {
        throw Exception('Failed to fetch verses from API');
      }
    } catch (e) {
      throw Exception('Failed to fetch verses: ${e.toString()}');
    }
  }

  Future<List<BibleVerse>> searchVerses({
    required String query,
    String version = 'KJV',
  }) async {
    try {
      // This would require local Bible database or advanced API
      // For now, returning empty list as placeholder
      return [];
    } catch (e) {
      throw Exception('Failed to search verses: ${e.toString()}');
    }
  }

  Future<void> addBookmark({
    required String userId,
    required String book,
    required int chapter,
    required int verse,
    String? note,
  }) async {
    try {
      await _supabase.from('bible_bookmarks').insert({
        'user_id': userId,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add bookmark: ${e.toString()}');
    }
  }

  Future<void> removeBookmark(String bookmarkId) async {
    try {
      await _supabase.from('bible_bookmarks').delete().eq('id', bookmarkId);
    } catch (e) {
      throw Exception('Failed to remove bookmark: ${e.toString()}');
    }
  }

  Future<List<BibleBookmark>> getBookmarks(String userId) async {
    try {
      final response = await _supabase
          .from('bible_bookmarks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((bookmark) => BibleBookmark.fromJson(bookmark))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookmarks: ${e.toString()}');
    }
  }
}
