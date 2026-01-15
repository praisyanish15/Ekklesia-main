import 'package:flutter/material.dart';

enum ChurchThemeType {
  spiritualBlue,
  holyPurple,
  graceGreen,
  divineRed,
  celestialDark,
}

class ChurchTheme {
  final ChurchThemeType type;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color textColor;
  final Color subtitleColor;
  final Brightness brightness;

  const ChurchTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.textColor,
    required this.subtitleColor,
    required this.brightness,
  });

  // Convert to string for database storage
  String get value {
    switch (type) {
      case ChurchThemeType.spiritualBlue:
        return 'spiritual_blue';
      case ChurchThemeType.holyPurple:
        return 'holy_purple';
      case ChurchThemeType.graceGreen:
        return 'grace_green';
      case ChurchThemeType.divineRed:
        return 'divine_red';
      case ChurchThemeType.celestialDark:
        return 'celestial_dark';
    }
  }

  // Create from database value
  static ChurchTheme fromValue(String value) {
    switch (value) {
      case 'spiritual_blue':
        return ChurchThemes.spiritualBlue;
      case 'holy_purple':
        return ChurchThemes.holyPurple;
      case 'grace_green':
        return ChurchThemes.graceGreen;
      case 'divine_red':
        return ChurchThemes.divineRed;
      case 'celestial_dark':
        return ChurchThemes.celestialDark;
      default:
        return ChurchThemes.spiritualBlue;
    }
  }

  // Generate ThemeData for Flutter
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        tertiary: accentColor,
        onTertiary: Colors.white,
        error: Colors.red[700]!,
        onError: Colors.white,
        surface: cardColor,
        onSurface: textColor,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: textColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: subtitleColor,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ChurchThemes {
  // 1. Spiritual Blue - Calm and peaceful, like the sky and water
  static const spiritualBlue = ChurchTheme(
    type: ChurchThemeType.spiritualBlue,
    name: 'Spiritual Blue',
    description: 'Peaceful blue tones with golden accents - representing heaven and divine peace',
    primaryColor: Color(0xFF1565C0), // Deep blue
    secondaryColor: Color(0xFF42A5F5), // Light blue
    accentColor: Color(0xFFFFB300), // Gold
    backgroundColor: Color(0xFFF5F8FA),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    subtitleColor: Color(0xFF666666),
    brightness: Brightness.light,
  );

  // 2. Holy Purple - Royal and majestic, representing royalty and divinity
  static const holyPurple = ChurchTheme(
    type: ChurchThemeType.holyPurple,
    name: 'Holy Purple',
    description: 'Royal purple with white and gold - symbolizing majesty and holiness',
    primaryColor: Color(0xFF6A1B9A), // Deep purple
    secondaryColor: Color(0xFFAB47BC), // Light purple
    accentColor: Color(0xFFFFD700), // Gold
    backgroundColor: Color(0xFFFAF7FB),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    subtitleColor: Color(0xFF666666),
    brightness: Brightness.light,
  );

  // 3. Grace Green - Natural and growing, representing life and renewal
  static const graceGreen = ChurchTheme(
    type: ChurchThemeType.graceGreen,
    name: 'Grace Green',
    description: 'Natural green with earth tones - symbolizing growth and new life',
    primaryColor: Color(0xFF2E7D32), // Deep green
    secondaryColor: Color(0xFF66BB6A), // Light green
    accentColor: Color(0xFF8D6E63), // Earth brown
    backgroundColor: Color(0xFFF7F9F7),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    subtitleColor: Color(0xFF666666),
    brightness: Brightness.light,
  );

  // 4. Divine Red - Passionate and powerful, representing the blood of Christ and fire of the Spirit
  static const divineRed = ChurchTheme(
    type: ChurchThemeType.divineRed,
    name: 'Divine Red',
    description: 'Deep red with cream accents - representing sacrifice and passion',
    primaryColor: Color(0xFFC62828), // Deep red
    secondaryColor: Color(0xFFE57373), // Light red
    accentColor: Color(0xFFFFD54F), // Warm gold
    backgroundColor: Color(0xFFFBF7F5),
    cardColor: Colors.white,
    textColor: Color(0xFF1A1A1A),
    subtitleColor: Color(0xFF666666),
    brightness: Brightness.light,
  );

  // 5. Celestial Dark - Modern dark theme with celestial blue
  static const celestialDark = ChurchTheme(
    type: ChurchThemeType.celestialDark,
    name: 'Celestial Dark',
    description: 'Dark theme with celestial blue accents - modern and contemplative',
    primaryColor: Color(0xFF42A5F5), // Celestial blue
    secondaryColor: Color(0xFF64B5F6), // Light celestial blue
    accentColor: Color(0xFFFFAB40), // Warm orange
    backgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    textColor: Color(0xFFE0E0E0),
    subtitleColor: Color(0xFF9E9E9E),
    brightness: Brightness.dark,
  );

  static List<ChurchTheme> get all => [
        spiritualBlue,
        holyPurple,
        graceGreen,
        divineRed,
        celestialDark,
      ];

  static ChurchTheme fromType(ChurchThemeType type) {
    return all.firstWhere((theme) => theme.type == type);
  }
}
