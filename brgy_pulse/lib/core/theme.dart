import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────
// Accent colors — same in both light and dark
// ──────────────────────────────────────────────

class AppColors {
  AppColors._();
  static const Color primary = Color(0xFF2563EB);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
}

// ──────────────────────────────────────────────
// Context extension for mode-dependent colors
// ──────────────────────────────────────────────

extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? const Color(0xFF121214) : const Color(0xFFF5F5F5);
  Color get surface => isDark ? const Color(0xFF1C1C1F) : Colors.white;
  Color get cardFill => isDark ? const Color(0xFF242428) : Colors.white;
  Color get border => isDark ? const Color(0xFF333338) : const Color(0xFFE2E4E9);
  Color get textPrimary => isDark ? const Color(0xFFE4E4E7) : const Color(0xFF1A1A2E);
  Color get textSecondary => isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
  Color get textMuted => isDark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF);
  Color get dividerClr => isDark ? const Color(0xFF2C2C30) : const Color(0xFFE5E7EB);
}

// ──────────────────────────────────────────────
// Theme definitions
// ──────────────────────────────────────────────

class AppTheme {
  AppTheme._();
  static const double r = 6.0; // border radius — sharp, not bubbly

  // ─── LIGHT (DEFAULT) ───────────────────────

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.warning,
        surface: Colors.white,
        error: AppColors.danger,
      ),
      useMaterial3: true,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
        iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r),
          side: const BorderSide(color: Color(0xFFE2E4E9), width: 1),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            color: sel ? AppColors.primary : const Color(0xFF9CA3AF),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? AppColors.primary : const Color(0xFF9CA3AF), size: 22);
        }),
      ),

      textTheme: _textTheme(
        primary: const Color(0xFF1A1A2E),
        secondary: const Color(0xFF6B7280),
        muted: const Color(0xFF9CA3AF),
      ),

      inputDecorationTheme: _inputTheme(
        fill: const Color(0xFFF9FAFB),
        border: const Color(0xFFE2E4E9),
        label: const Color(0xFF6B7280),
        hint: const Color(0xFF9CA3AF),
      ),

      elevatedButtonTheme: _elevatedBtn(),
      outlinedButtonTheme: _outlinedBtn(borderColor: const Color(0xFFE2E4E9)),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(r + 4)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A2E),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── DARK (MUTED) ─────────────────────────

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121214),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.warning,
        surface: Color(0xFF1C1C1F),
        error: AppColors.danger,
      ),
      useMaterial3: true,

      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1C1C1F),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFE4E4E7)),
        iconTheme: const IconThemeData(color: Color(0xFFA1A1AA)),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF242428),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r),
          side: const BorderSide(color: Color(0xFF333338), width: 1),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: const Color(0xFF1C1C1F),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.10),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
            color: sel ? AppColors.primary : const Color(0xFF71717A),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? AppColors.primary : const Color(0xFF71717A), size: 22);
        }),
      ),

      textTheme: _textTheme(
        primary: const Color(0xFFE4E4E7),
        secondary: const Color(0xFFA1A1AA),
        muted: const Color(0xFF71717A),
      ),

      inputDecorationTheme: _inputTheme(
        fill: const Color(0xFF1C1C1F),
        border: const Color(0xFF333338),
        label: const Color(0xFFA1A1AA),
        hint: const Color(0xFF71717A),
      ),

      elevatedButtonTheme: _elevatedBtn(),
      outlinedButtonTheme: _outlinedBtn(borderColor: const Color(0xFF333338)),
      dividerTheme: const DividerThemeData(color: Color(0xFF2C2C30), thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF1C1C1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(r + 4)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF242428),
        contentTextStyle: GoogleFonts.inter(color: const Color(0xFFE4E4E7), fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── SHARED HELPERS ─────────────────────────

  static TextTheme _textTheme({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    return TextTheme(
      headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: primary),
      bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: secondary),
      bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: muted),
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: muted, letterSpacing: 0.5),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color label,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(r), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      labelStyle: GoogleFonts.inter(color: label, fontSize: 13),
      hintStyle: GoogleFonts.inter(color: hint, fontSize: 13),
    );
  }

  static ElevatedButtonThemeData _elevatedBtn() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedBtn({required Color borderColor}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
