import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ChurchThemeType {
  ekklesiaLight,
  ekklesiaDark,
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
      case ChurchThemeType.ekklesiaLight:
        return 'ekklesia_light';
      case ChurchThemeType.ekklesiaDark:
        return 'ekklesia_dark';
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
      case 'ekklesia_light':
        return ChurchThemes.ekklesiaLight;
      case 'ekklesia_dark':
        return ChurchThemes.ekklesiaDark;
      case 'ekklesia_gold': // Legacy support
        return ChurchThemes.ekklesiaDark;
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
        return ChurchThemes.ekklesiaLight;
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
        elevation: brightness == Brightness.light ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: brightness == Brightness.light
            ? BorderSide(color: const Color(0xFFE5E5E0), width: 1)
            : BorderSide.none,
        ),
      ),
      iconTheme: IconThemeData(
        color: primaryColor, // Active state: Soft Gold
        size: 24,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor, // Active: Gold
        unselectedItemColor: subtitleColor, // Inactive: Slate Gray
        selectedIconTheme: IconThemeData(color: primaryColor),
        unselectedIconTheme: IconThemeData(color: subtitleColor),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: brightness == Brightness.light ? const Color(0xFF0B1929) : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          // Headings use Cormorant Garamond (serif, reverent)
          headlineLarge: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          headlineMedium: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          headlineSmall: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.cormorantGaramond(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          // Body text uses Inter (clean sans-serif)
          bodyLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
          bodyMedium: GoogleFonts.inter(
            color: subtitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.inter(
            color: subtitleColor,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: GoogleFonts.inter(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class ChurchThemes {
  // 0. Ekklesia Light - Light mode with Off-White background and Soft Gold accents
  static const ekklesiaLight = ChurchTheme(
    type: ChurchThemeType.ekklesiaLight,
    name: 'Ekklesia Light',
    description: 'Off-White with Soft Gold accents - clean and reverent',
    primaryColor: Color(0xFFD4A574), // Soft Gold
    secondaryColor: Color(0xFFE8B88B), // Light Soft Gold
    accentColor: Color(0xFFB8956A), // Darker Soft Gold
    backgroundColor: Color(0xFFF5F5F0), // Off-White
    cardColor: Color(0xFFFFFFFF), // White cards
    textColor: Color(0xFF2D3748), // Charcoal
    subtitleColor: Color(0xFF64748B), // Slate Gray
    brightness: Brightness.light,
  );

  // 1. Ekklesia Dark - Dark mode with Midnight Blue and Soft Gold glow
  static const ekklesiaDark = ChurchTheme(
    type: ChurchThemeType.ekklesiaDark,
    name: 'Ekklesia Dark',
    description: 'Midnight Blue with Soft Gold glow - contemplative and sacred',
    primaryColor: Color(0xFFD4A574), // Soft Gold
    secondaryColor: Color(0xFFE8B88B), // Light Soft Gold
    accentColor: Color(0xFFB8956A), // Darker Soft Gold
    backgroundColor: Color(0xFF0B1929), // Midnight Blue
    cardColor: Color(0xFF14233B), // Darker card for dark mode
    textColor: Color(0xFFF5F5F0), // Off-White
    subtitleColor: Color(0xFF94A3B8), // Slate Gray
    brightness: Brightness.dark,
  );

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
        ekklesiaLight,
        ekklesiaDark,
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
