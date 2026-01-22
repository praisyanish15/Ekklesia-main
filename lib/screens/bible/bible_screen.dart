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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibleProvider>().loadSettings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const _BibleSettingsSheet(),
    );
  }

  void _showBookmarks() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _BookmarksScreen()),
    );
  }

  void _searchReference() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final parts = query.split(' ');
    if (parts.length < 2) return;

    final book = parts.sublist(0, parts.length - 1).join(' ');
    final chapterVerse = parts.last.split(':');
    final chapter = int.tryParse(chapterVerse.first);

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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
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
                          builder: (_) => const BibleBooksScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark),
                    onPressed: _showBookmarks,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showSettings,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<BibleProvider>(
                  builder: (_, bibleProvider, __) {
                    if (bibleProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (bibleProvider.currentVerses.isEmpty) {
                      return const Center(
                        child: Text(
                          'Search for a Bible verse\n(e.g., John 3:16)',
                          textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

/* ---------------- Bible Content ---------------- */

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
        border: Border.all(color: Colors.grey),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: verses.length,
        itemBuilder: (_, index) {
          final verse = verses[index];
          return _VerseItem(
            verse: verse,
            fontSize: settings.fontSize,
            isDarkMode: settings.isDarkMode,
          );
        },
      ),
    );
  }
}

/* ---------------- Verse Item ---------------- */

class _VerseItem extends StatelessWidget {
  final BibleVerse verse;
  final double fontSize;
  final bool isDarkMode;

  const _VerseItem({
    required this.verse,
    required this.fontSize,
    required this.isDarkMode,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmark_add),
            title: const Text('Bookmark'),
            onTap: () async {
              final auth = context.read<AuthProvider>();
              final bible = context.read<BibleProvider>();

              Navigator.pop(context);

              if (auth.currentUser != null) {
                await bible.addBookmark(
                  userId: auth.currentUser!.id,
                  book: verse.book,
                  chapter: verse.chapter,
                  verse: verse.verse,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              Share.share(
                '${verse.reference}\n\n${verse.text}',
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
      onTap: () => _showOptions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: fontSize,
              color: isDarkMode ? Colors.white : Colors.black,
              height: 1.6,
            ),
            children: [
              TextSpan(
                text: '${verse.verse} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: verse.text),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- Settings ---------------- */

class _BibleSettingsSheet extends StatelessWidget {
  const _BibleSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BibleProvider>(
      builder: (_, bibleProvider, __) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bible Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: bibleProvider.settings.version,
                items: AppConstants.bibleVersions
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    bibleProvider.updateSettings(version: v);
                  }
                },
              ),
              Slider(
                value: bibleProvider.settings.fontSize,
                min: AppConstants.minFontSize,
                max: AppConstants.maxFontSize,
                onChanged: (v) {
                  bibleProvider.updateSettings(fontSize: v);
                },
              ),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: bibleProvider.settings.isDarkMode,
                onChanged: (v) {
                  bibleProvider.updateSettings(isDarkMode: v);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ---------------- Bookmarks ---------------- */

class _BookmarksScreen extends StatefulWidget {
  const _BookmarksScreen();

  @override
  State<_BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<_BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      context.read<BibleProvider>().loadBookmarks(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: Consumer<BibleProvider>(
        builder: (_, bibleProvider, __) {
          if (bibleProvider.bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks'));
          }

          return ListView.builder(
            itemCount: bibleProvider.bookmarks.length,
            itemBuilder: (_, i) {
              final b = bibleProvider.bookmarks[i];
              return ListTile(
                title: Text(b.reference),
                onTap: () {
                  bibleProvider.fetchVerses(
                    book: b.book,
                    chapter: b.chapter,
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
