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
      // Format book name for API (replace spaces with +)
      final formattedBook = book.replaceAll(' ', '+');

      // Try KJV API first
      final url = 'https://bible-api.com/$formattedBook+$chapter';
      print('Fetching from: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final verses = <BibleVerse>[];

        if (data['verses'] != null && data['verses'] is List) {
          for (var verse in data['verses']) {
            verses.add(BibleVerse(
              book: book,
              chapter: chapter,
              verse: verse['verse'] as int,
              text: (verse['text'] as String).trim(),
              version: 'KJV', // bible-api.com uses KJV
            ));
          }
        } else if (data['text'] != null) {
          // Alternative format - single text with all verses
          final text = data['text'] as String;
          verses.add(BibleVerse(
            book: book,
            chapter: chapter,
            verse: 1,
            text: text,
            version: 'KJV',
          ));
        }

        if (verses.isEmpty) {
          throw Exception('No verses found for $book chapter $chapter');
        }

        return verses;
      } else if (response.statusCode == 404) {
        throw Exception('Book "$book" chapter $chapter not found. Please check the book name and chapter number.');
      } else {
        throw Exception('Failed to fetch verses (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('No internet connection. Please check your network and try again.');
      }
      throw Exception('Error: ${e.toString()}');
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
