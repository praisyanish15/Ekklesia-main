import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/bible_provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/app_constants.dart';
import '../../models/bible_model.dart';
import 'bible_books_screen.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BibleProvider>().loadSettings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _BibleSettingsSheet(),
    );
  }

  void _showBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const _BookmarksScreen(),
      ),
    );
  }

  void _searchReference() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Parse reference (e.g., "John 3:16" or "Genesis 1:1")
    final parts = query.split(' ');
    if (parts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid reference (e.g., John 3:16)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final book = parts.sublist(0, parts.length - 1).join(' ');
    final chapterVerse = parts.last.split(':');

    if (chapterVerse.isEmpty) return;

    final chapter = int.tryParse(chapterVerse[0]);
    if (chapter == null) return;

    context.read<BibleProvider>().fetchVerses(
          book: book,
          chapter: chapter,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search (e.g., John 3:16)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _searchReference(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BibleBooksScreen(),
                    ),
                  );
                },
                tooltip: 'Browse Books',
              ),
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: _showBookmarks,
                tooltip: 'Bookmarks',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettings,
                tooltip: 'Settings',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bible Content
          Expanded(
            child: Consumer<BibleProvider>(
              builder: (context, bibleProvider, child) {
                if (bibleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bibleProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          bibleProvider.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (bibleProvider.currentVerses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Search for a Bible verse\ne.g., John 3:16',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return _BibleContent(
                  verses: bibleProvider.currentVerses,
                  settings: bibleProvider.settings,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BibleContent extends StatelessWidget {
  final List<BibleVerse> verses;
  final BibleSettings settings;

  const _BibleContent({
    required this.verses,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verse = verses[index];
          return _VerseItem(
            verse: verse,
            fontSize: settings.fontSize,
            isDarkMode: settings.isDarkMode,
          );
        },
      ),
          ),
        ),
      ),
    );
  }
}

class _VerseItem extends StatelessWidget {
  final BibleVerse verse;
  final double fontSize;
  final bool isDarkMode;

  const _VerseItem({
    required this.verse,
    required this.fontSize,
    required this.isDarkMode,
  });

  void _showVerseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_add),
            title: const Text('Bookmark'),
            onTap: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final bibleProvider = context.read<BibleProvider>();

              if (authProvider.currentUser != null) {
                final success = await bibleProvider.addBookmark(
                  userId: authProvider.currentUser!.id,
                  book: verse.book,
                  chapter: verse.chapter,
                  verse: verse.verse,
                );

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bookmark added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              Share.share(
                '${verse.reference}\n\n${verse.text}\n\n- ${verse.version}',
                subject: verse.reference,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showVerseOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: '${verse.verse} ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                ),
              ),
              TextSpan(text: verse.text),
            ],
          ),
        ),
      ),
    );
  }
}

class _BibleSettingsSheet extends StatelessWidget {
  const _BibleSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (context, bibleProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bible Settings',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Version Selection
              const Text('Bible Version'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: bibleProvider.settings.version,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.bibleVersions
                    .map((version) => DropdownMenuItem(
                          value: version,
                          child: Text(version),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    bibleProvider.updateSettings(version: value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Font Size
              const Text('Font Size'),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: bibleProvider.settings.fontSize,
                      min: AppConstants.minFontSize,
                      max: AppConstants.maxFontSize,
                      divisions: 18,
                      label: bibleProvider.settings.fontSize.round().toString(),
                      onChanged: (value) {
                        bibleProvider.updateSettings(fontSize: value);
                      },
                    ),
                  ),
                  Text('${bibleProvider.settings.fontSize.round()}'),
                ],
              ),
              const SizedBox(height: 16),

              // Theme Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: bibleProvider.settings.isDarkMode,
                onChanged: (value) {
                  bibleProvider.updateSettings(isDarkMode: value);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _BookmarksScreen extends StatefulWidget {
  const _BookmarksScreen();

  @override
  State<_BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<_BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final bibleProvider = context.read<BibleProvider>();
    if (authProvider.currentUser != null) {
      bibleProvider.loadBookmarks(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: Consumer<BibleProvider>(
        builder: (context, bibleProvider, child) {
          if (bibleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bibleProvider.bookmarks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bibleProvider.bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bibleProvider.bookmarks[index];
              return ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text(bookmark.reference),
                subtitle: bookmark.note != null ? Text(bookmark.note!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    if (authProvider.currentUser != null) {
                      await bibleProvider.removeBookmark(
                        bookmark.id,
                        authProvider.currentUser!.id,
                      );
                    }
                  },
                ),
                onTap: () {
                  bibleProvider.fetchVerses(
                    book: bookmark.book,
                    chapter: bookmark.chapter,
                  );
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
