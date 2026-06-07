import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ============================================================================
  // COLOR SYSTEM - Modern, Professional Palette
  // ============================================================================

  // Primary Colors
  static const Color primaryDark = Color(0xFF4F46E5); // Deep Indigo
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8); // Light Indigo

  // Secondary Colors
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE); // Light Cyan

  // Accent Colors
  static const Color accent = Color(0xFF9333EA); // Purple
  static const Color accentLight = Color(0xFFA855F7); // Light Purple

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFF43F5E); // Rose
  static const Color info = Color(0xFF3B82F6); // Blue

  // Neutral Colors - Light Mode
  static const Color bgLight = Color(0xFFFAFAFA); // Nearly white
  static const Color surfaceLight = Color(0xFFF3F4F6); // Light gray surface
  static const Color cardLight = Color(0xFFFFFFFF); // White
  static const Color borderLight = Color(0xFFE5E7EB); // Light border
  static const Color textDarkLight = Color(0xFF1F2937); // Dark text
  static const Color textGrayLight = Color(0xFF6B7280); // Gray text
  static const Color textMutedLight = Color(0xFF9CA3AF); // Muted text

  // Neutral Colors - Dark Mode
  static const Color bgDark = Color(0xFF0F172A); // Almost black
  static const Color surfaceDark = Color(0xFF1E293B); // Dark surface
  static const Color cardDark = Color(0xFF334155); // Dark card
  static const Color borderDark = Color(0xFF475569); // Dark border
  static const Color textDarkDark = Color(0xFFF1F5F9); // Light text in dark
  static const Color textGrayDark = Color(0xFFCBD5E1); // Gray text in dark
  static const Color textMutedDark = Color(0xFF94A3B8); // Muted text in dark

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ============================================================================
  // CORNER RADIUS SYSTEM
  // ============================================================================

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusFull = 999;

  // ============================================================================
  // SHADOW SYSTEM
  // ============================================================================

  static const List<BoxShadow> shadowSoft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(color: Color(0x20000000), blurRadius: 25, offset: Offset(0, 20)),
  ];

  static const List<BoxShadow> shadowExtraLarge = [
    BoxShadow(color: Color(0x25000000), blurRadius: 40, offset: Offset(0, 30)),
  ];

  // Glow shadows for buttons
  static List<BoxShadow> shadowGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: color.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  // ============================================================================
  // GRADIENTS - Premium & Modern
  // ============================================================================

  static const LinearGradient gradientPrimaryToSecondary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient gradientPrimaryToAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, accent],
  );

  static const LinearGradient gradientDeepToLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient gradientSuccessGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF34D399)],
  );

  static const LinearGradient gradientWarningGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, Color(0xFFFCD34D)],
  );

  static const Color surfaceColor = bgLight;
  static const LinearGradient mainGradient = gradientPrimaryToSecondary;

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    primaryColorDark: primaryDark,
    scaffoldBackgroundColor: bgLight,
    canvasColor: bgLight,
    cardColor: cardLight,
    dividerColor: borderLight,
    splashColor: primary.withOpacity(0.1),
    highlightColor: primary.withOpacity(0.05),
    hoverColor: primary.withOpacity(0.08),
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: textDarkLight,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textDarkLight,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDarkLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDarkLight,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrayLight,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMutedLight,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textGrayLight,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMutedLight,
        letterSpacing: 0.5,
      ),
    ),
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: textDarkLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDarkLight,
      ),
    ),
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: borderLight, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      hintStyle: const TextStyle(color: textMutedLight, fontSize: 14),
      labelStyle: const TextStyle(color: textGrayLight, fontSize: 14),
      errorStyle: const TextStyle(color: danger, fontSize: 12),
      prefixIconColor: textMutedLight,
      suffixIconColor: textMutedLight,
    ),
    // Card Theme
    cardTheme: const CardThemeData(
      color: cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
        side: BorderSide(color: borderLight),
      ),
    ),
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primary,
      unselectedItemColor: textMutedLight,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: md, vertical: xs),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      backgroundColor: surfaceLight,
      selectedColor: primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
  );

  // ============================================================================
  // DARK THEME
  // ============================================================================

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primary,
    primaryColorDark: primaryDark,
    scaffoldBackgroundColor: bgDark,
    canvasColor: bgDark,
    cardColor: cardDark,
    dividerColor: borderDark,
    splashColor: secondary.withOpacity(0.1),
    highlightColor: secondary.withOpacity(0.05),
    hoverColor: secondary.withOpacity(0.08),
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: textDarkDark,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: textDarkDark,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDarkDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDarkDark,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textGrayDark,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMutedDark,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textGrayDark,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMutedDark,
        letterSpacing: 0.5,
      ),
    ),
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: textDarkDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDarkDark,
      ),
    ),
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: secondary,
        side: const BorderSide(color: borderDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondary,
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        borderSide: const BorderSide(color: danger, width: 2),
      ),
      hintStyle: const TextStyle(color: textMutedDark, fontSize: 14),
      labelStyle: const TextStyle(color: textGrayDark, fontSize: 14),
      errorStyle: const TextStyle(color: danger, fontSize: 12),
      prefixIconColor: textMutedDark,
      suffixIconColor: textMutedDark,
    ),
    // Card Theme
    cardTheme: const CardThemeData(
      color: cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLg)),
        side: BorderSide(color: borderDark),
      ),
    ),
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: secondary,
      unselectedItemColor: textMutedDark,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: md, vertical: xs),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      backgroundColor: surfaceDark,
      selectedColor: secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
    ),
  );

  static final ThemeData theme = lightTheme;
}
