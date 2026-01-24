import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/song_model.dart';
import '../models/song_suggestion.dart';

class SongSuggestionService {
  List<SongSuggestionMapping>? _mappings;
  bool _isLoaded = false;

  /// Load the suggestion mappings from the bundled JSON file
  Future<void> _loadMappings() async {
    if (_isLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('lib/assets/song_suggestions.json');
      final jsonData = json.decode(jsonString);
      final mappingsList = jsonData['mappings'] as List;

      _mappings = mappingsList
          .map((m) => SongSuggestionMapping.fromJson(m as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      print('Failed to load song suggestions: $e');
      _mappings = [];
      _isLoaded = true;
    }
  }

  /// Get suggestions for a given song
  /// Returns null if no matching suggestions found
  Future<SongSuggestion?> getSuggestionsForSong(Song song) async {
    await _loadMappings();

    if (_mappings == null || _mappings!.isEmpty) {
      return null;
    }

    // Combine title and lyrics for matching
    final searchText = '${song.title} ${song.lyrics}'.toLowerCase();

    // Find all matching mappings and calculate scores
    final matchedMappings = <SongSuggestionMapping, int>{};

    for (final mapping in _mappings!) {
      final score = mapping.matchScore(searchText);
      if (score > 0) {
        matchedMappings[mapping] = score;
      }
    }

    if (matchedMappings.isEmpty) {
      return null;
    }

    // Sort by score (descending) and take the best match
    final sortedMappings = matchedMappings.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return the suggestion from the best matching mapping
    return sortedMappings.first.key.suggestion;
  }

  /// Get suggestions for a song by title only
  /// Useful for quick lookups without full lyrics
  Future<SongSuggestion?> getSuggestionsForTitle(String title) async {
    await _loadMappings();

    if (_mappings == null || _mappings!.isEmpty) {
      return null;
    }

    final searchText = title.toLowerCase();

    // Find the best matching mapping
    SongSuggestionMapping? bestMatch;
    int bestScore = 0;

    for (final mapping in _mappings!) {
      final score = mapping.matchScore(searchText);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = mapping;
      }
    }

    return bestMatch?.suggestion;
  }

  /// Clear cached mappings (useful for testing or refresh)
  void clearCache() {
    _mappings = null;
    _isLoaded = false;
  }
}
