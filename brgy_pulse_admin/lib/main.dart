import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'screens/admin_shell.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BrgyPulseAdminApp(),
    ),
  );
}

class BrgyPulseAdminApp extends StatelessWidget {
  const BrgyPulseAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrgyPulse Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AdminColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AdminColors.primary,
          secondary: AdminColors.warning,
          surface: AdminColors.surface,
          error: AdminColors.danger,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AdminColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AdminColors.textSecondary),
        ),
        cardTheme: CardThemeData(
          color: AdminColors.card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AdminColors.cardBorder, width: 1),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 64,
          backgroundColor: AdminColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AdminColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AdminColors.primary : AdminColors.textMuted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AdminColors.primary : AdminColors.textMuted,
              size: 22,
            );
          }),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700, color: AdminColors.textPrimary),
          headlineMedium: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
          headlineSmall: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
          titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
          titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AdminColors.textPrimary),
          bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: AdminColors.textPrimary),
          bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: AdminColors.textSecondary),
          bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: AdminColors.textMuted),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AdminColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AdminColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
          ),
          labelStyle: GoogleFonts.inter(color: AdminColors.textSecondary, fontSize: 13),
          hintStyle: GoogleFonts.inter(color: AdminColors.textMuted, fontSize: 13),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AdminColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminColors.textPrimary,
            side: const BorderSide(color: AdminColors.cardBorder),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AdminColors.card,
          contentTextStyle: GoogleFonts.inter(color: AdminColors.textPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const AdminShell(),
    );
  }
}
