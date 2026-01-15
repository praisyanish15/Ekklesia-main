import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_model.dart';
import '../services/bible_service.dart';

class BibleProvider with ChangeNotifier {
  final BibleService _bibleService = BibleService();

  BibleSettings _settings = BibleSettings();
  List<BibleVerse> _currentVerses = [];
  List<BibleBookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _errorMessage;

  BibleSettings get settings => _settings;
  List<BibleVerse> get currentVerses => _currentVerses;
  List<BibleBookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = BibleSettings(
      version: prefs.getString('bible_version') ?? 'KJV',
      fontSize: prefs.getDouble('bible_font_size') ?? 16.0,
      isDarkMode: prefs.getBool('bible_dark_mode') ?? false,
    );
    notifyListeners();
  }

  Future<void> updateSettings({
    String? version,
    double? fontSize,
    bool? isDarkMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (version != null) {
      await prefs.setString('bible_version', version);
    }
    if (fontSize != null) {
      await prefs.setDouble('bible_font_size', fontSize);
    }
    if (isDarkMode != null) {
      await prefs.setBool('bible_dark_mode', isDarkMode);
    }

    _settings = _settings.copyWith(
      version: version,
      fontSize: fontSize,
      isDarkMode: isDarkMode,
    );
    notifyListeners();
  }

  Future<void> fetchVerses({
    required String book,
    required int chapter,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentVerses = await _bibleService.fetchVerses(
        book: book,
        chapter: chapter,
        version: _settings.version,
      );
    } catch (e) {
      _errorMessage = e.toString();
      _currentVerses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookmarks(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await _bibleService.getBookmarks(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBookmark({
    required String userId,
    required String book,
    required int chapter,
    required int verse,
    String? note,
  }) async {
    try {
      await _bibleService.addBookmark(
        userId: userId,
        book: book,
        chapter: chapter,
        verse: verse,
        note: note,
      );
      await loadBookmarks(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> removeBookmark(String bookmarkId, String userId) async {
    try {
      await _bibleService.removeBookmark(bookmarkId);
      await loadBookmarks(userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
