class BibleBook {
  final String name;
  final String abbreviation;
  final int chapters;
  final Testament testament;

  const BibleBook({
    required this.name,
    required this.abbreviation,
    required this.chapters,
    required this.testament,
  });
}

enum Testament {
  old,
  newTestament,
}

class BibleBooks {
  // Old Testament Books
  static const List<BibleBook> oldTestament = [
    // Pentateuch (Torah)
    BibleBook(name: 'Genesis', abbreviation: 'Gen', chapters: 50, testament: Testament.old),
    BibleBook(name: 'Exodus', abbreviation: 'Exod', chapters: 40, testament: Testament.old),
    BibleBook(name: 'Leviticus', abbreviation: 'Lev', chapters: 27, testament: Testament.old),
    BibleBook(name: 'Numbers', abbreviation: 'Num', chapters: 36, testament: Testament.old),
    BibleBook(name: 'Deuteronomy', abbreviation: 'Deut', chapters: 34, testament: Testament.old),

    // Historical Books
    BibleBook(name: 'Joshua', abbreviation: 'Josh', chapters: 24, testament: Testament.old),
    BibleBook(name: 'Judges', abbreviation: 'Judg', chapters: 21, testament: Testament.old),
    BibleBook(name: 'Ruth', abbreviation: 'Ruth', chapters: 4, testament: Testament.old),
    BibleBook(name: '1 Samuel', abbreviation: '1 Sam', chapters: 31, testament: Testament.old),
    BibleBook(name: '2 Samuel', abbreviation: '2 Sam', chapters: 24, testament: Testament.old),
    BibleBook(name: '1 Kings', abbreviation: '1 Kgs', chapters: 22, testament: Testament.old),
    BibleBook(name: '2 Kings', abbreviation: '2 Kgs', chapters: 25, testament: Testament.old),
    BibleBook(name: '1 Chronicles', abbreviation: '1 Chr', chapters: 29, testament: Testament.old),
    BibleBook(name: '2 Chronicles', abbreviation: '2 Chr', chapters: 36, testament: Testament.old),
    BibleBook(name: 'Ezra', abbreviation: 'Ezra', chapters: 10, testament: Testament.old),
    BibleBook(name: 'Nehemiah', abbreviation: 'Neh', chapters: 13, testament: Testament.old),
    BibleBook(name: 'Esther', abbreviation: 'Esth', chapters: 10, testament: Testament.old),

    // Wisdom Books
    BibleBook(name: 'Job', abbreviation: 'Job', chapters: 42, testament: Testament.old),
    BibleBook(name: 'Psalms', abbreviation: 'Ps', chapters: 150, testament: Testament.old),
    BibleBook(name: 'Proverbs', abbreviation: 'Prov', chapters: 31, testament: Testament.old),
    BibleBook(name: 'Ecclesiastes', abbreviation: 'Eccl', chapters: 12, testament: Testament.old),
    BibleBook(name: 'Song of Solomon', abbreviation: 'Song', chapters: 8, testament: Testament.old),

    // Major Prophets
    BibleBook(name: 'Isaiah', abbreviation: 'Isa', chapters: 66, testament: Testament.old),
    BibleBook(name: 'Jeremiah', abbreviation: 'Jer', chapters: 52, testament: Testament.old),
    BibleBook(name: 'Lamentations', abbreviation: 'Lam', chapters: 5, testament: Testament.old),
    BibleBook(name: 'Ezekiel', abbreviation: 'Ezek', chapters: 48, testament: Testament.old),
    BibleBook(name: 'Daniel', abbreviation: 'Dan', chapters: 12, testament: Testament.old),

    // Minor Prophets
    BibleBook(name: 'Hosea', abbreviation: 'Hos', chapters: 14, testament: Testament.old),
    BibleBook(name: 'Joel', abbreviation: 'Joel', chapters: 3, testament: Testament.old),
    BibleBook(name: 'Amos', abbreviation: 'Amos', chapters: 9, testament: Testament.old),
    BibleBook(name: 'Obadiah', abbreviation: 'Obad', chapters: 1, testament: Testament.old),
    BibleBook(name: 'Jonah', abbreviation: 'Jonah', chapters: 4, testament: Testament.old),
    BibleBook(name: 'Micah', abbreviation: 'Mic', chapters: 7, testament: Testament.old),
    BibleBook(name: 'Nahum', abbreviation: 'Nah', chapters: 3, testament: Testament.old),
    BibleBook(name: 'Habakkuk', abbreviation: 'Hab', chapters: 3, testament: Testament.old),
    BibleBook(name: 'Zephaniah', abbreviation: 'Zeph', chapters: 3, testament: Testament.old),
    BibleBook(name: 'Haggai', abbreviation: 'Hag', chapters: 2, testament: Testament.old),
    BibleBook(name: 'Zechariah', abbreviation: 'Zech', chapters: 14, testament: Testament.old),
    BibleBook(name: 'Malachi', abbreviation: 'Mal', chapters: 4, testament: Testament.old),
  ];

  // New Testament Books
  static const List<BibleBook> newTestament = [
    // Gospels
    BibleBook(name: 'Matthew', abbreviation: 'Matt', chapters: 28, testament: Testament.newTestament),
    BibleBook(name: 'Mark', abbreviation: 'Mark', chapters: 16, testament: Testament.newTestament),
    BibleBook(name: 'Luke', abbreviation: 'Luke', chapters: 24, testament: Testament.newTestament),
    BibleBook(name: 'John', abbreviation: 'John', chapters: 21, testament: Testament.newTestament),

    // History
    BibleBook(name: 'Acts', abbreviation: 'Acts', chapters: 28, testament: Testament.newTestament),

    // Pauline Epistles
    BibleBook(name: 'Romans', abbreviation: 'Rom', chapters: 16, testament: Testament.newTestament),
    BibleBook(name: '1 Corinthians', abbreviation: '1 Cor', chapters: 16, testament: Testament.newTestament),
    BibleBook(name: '2 Corinthians', abbreviation: '2 Cor', chapters: 13, testament: Testament.newTestament),
    BibleBook(name: 'Galatians', abbreviation: 'Gal', chapters: 6, testament: Testament.newTestament),
    BibleBook(name: 'Ephesians', abbreviation: 'Eph', chapters: 6, testament: Testament.newTestament),
    BibleBook(name: 'Philippians', abbreviation: 'Phil', chapters: 4, testament: Testament.newTestament),
    BibleBook(name: 'Colossians', abbreviation: 'Col', chapters: 4, testament: Testament.newTestament),
    BibleBook(name: '1 Thessalonians', abbreviation: '1 Thess', chapters: 5, testament: Testament.newTestament),
    BibleBook(name: '2 Thessalonians', abbreviation: '2 Thess', chapters: 3, testament: Testament.newTestament),
    BibleBook(name: '1 Timothy', abbreviation: '1 Tim', chapters: 6, testament: Testament.newTestament),
    BibleBook(name: '2 Timothy', abbreviation: '2 Tim', chapters: 4, testament: Testament.newTestament),
    BibleBook(name: 'Titus', abbreviation: 'Titus', chapters: 3, testament: Testament.newTestament),
    BibleBook(name: 'Philemon', abbreviation: 'Phlm', chapters: 1, testament: Testament.newTestament),

    // General Epistles
    BibleBook(name: 'Hebrews', abbreviation: 'Heb', chapters: 13, testament: Testament.newTestament),
    BibleBook(name: 'James', abbreviation: 'Jas', chapters: 5, testament: Testament.newTestament),
    BibleBook(name: '1 Peter', abbreviation: '1 Pet', chapters: 5, testament: Testament.newTestament),
    BibleBook(name: '2 Peter', abbreviation: '2 Pet', chapters: 3, testament: Testament.newTestament),
    BibleBook(name: '1 John', abbreviation: '1 John', chapters: 5, testament: Testament.newTestament),
    BibleBook(name: '2 John', abbreviation: '2 John', chapters: 1, testament: Testament.newTestament),
    BibleBook(name: '3 John', abbreviation: '3 John', chapters: 1, testament: Testament.newTestament),
    BibleBook(name: 'Jude', abbreviation: 'Jude', chapters: 1, testament: Testament.newTestament),

    // Prophecy
    BibleBook(name: 'Revelation', abbreviation: 'Rev', chapters: 22, testament: Testament.newTestament),
  ];

  static List<BibleBook> get allBooks => [...oldTestament, ...newTestament];
}
