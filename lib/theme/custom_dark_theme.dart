import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom typography and color theme tailored for Web Applications.
/// Since web screens provide more real estate than mobile devices, 
/// the font sizes are scaled up accordingly to ensure high readability.
class WebTheme {
  // Define custom colors
  static const Color primaryColor = Color(0xFF1A73E8); // Classic digital blue
  static const Color backgroundColor = Color(0xFF121212); // Dark background for contrast
  static const Color textWhite = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get darkWebTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // Defining the complete text theme using Google Sans (via GoogleFonts.openSans or similar package)
      // Note: "Google Sans" is proprietary to Google, so "Product Sans" or "Open Sans" / "Inter" 
      // are standard equivalents in Google Fonts. We use GoogleFonts.openSans as a highly clean base 
      // or customize the font family string to use your locally hosted 'Google Sans'.
      textTheme: TextTheme(
        // DISPLAY STYLES (Used for massive banners, hero sections on websites)
        displayLarge: GoogleFonts.googleSans(
          fontSize: 64.0,
          fontWeight: FontWeight.bold,
          color: textWhite,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.googleSans(
          fontSize: 48.0,
          fontWeight: FontWeight.bold,
          color: textWhite,
          letterSpacing: -1.0,
        ),
        displaySmall: GoogleFonts.googleSans(
          fontSize: 36.0,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),

        // HEADINGS (Standard web section titles)
        headlineLarge: GoogleFonts.googleSans(
          fontSize: 32.0, // H1 equivalent for large desktop
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 255, 255, 255),
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.googleSans(
          fontSize: 28.0, // H2 equivalent
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        headlineSmall: GoogleFonts.googleSans(
          fontSize: 24.0, // H3 equivalent
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),

        // TITLES (Card headers, sub-sections, navigation bars)
        titleLarge: GoogleFonts.googleSans(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
          color: textWhite,
        ),
        titleMedium: GoogleFonts.googleSans(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: textWhite,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.googleSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: textWhite,
          letterSpacing: 0.1,
        ),

        // BODY TEXT (Main paragraphs, article content)
        bodyLarge: GoogleFonts.googleSans(
          fontSize: 18.0, // Enlarged body text for clean readability on desktop screens
          fontWeight: FontWeight.normal,
          color: textWhite,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.googleSans(
          fontSize: 16.0, // Standard paragraph text
          fontWeight: FontWeight.normal,
          color: textWhite,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.googleSans(
          fontSize: 14.0, // Secondary paragraph text / captions
          fontWeight: FontWeight.normal,
          color: textSecondary,
          letterSpacing: 0.4,
        ),

        // LABELS (Buttons, tags, form fields)
        labelLarge: GoogleFonts.googleSans(
          fontSize: 16.0, // Button text
          fontWeight: FontWeight.w600,
          color: textWhite,
          letterSpacing: 1.25,
        ),
        labelMedium: GoogleFonts.googleSans(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: textWhite,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.googleSans(
          fontSize: 11.0,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}