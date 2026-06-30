import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'services/supabase_service.dart';
import 'screens/admin_shell.dart';
import 'screens/auth/admin_login_screen.dart';
import 'mesh/services/mesh_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  await MeshStorage.initialize();

  runApp(
    const ProviderScope(
      child: BrgyPulseAdminApp(),
    ),
  );
}

class BrgyPulseAdminApp extends StatefulWidget {
  const BrgyPulseAdminApp({super.key});

  @override
  State<BrgyPulseAdminApp> createState() => _BrgyPulseAdminAppState();
}

class _BrgyPulseAdminAppState extends State<BrgyPulseAdminApp> {
  bool _isGuest = false;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SupabaseService.isLoggedIn || _isGuest || !SupabaseService.isConfigured;

    return MaterialApp(
      title: 'BrgyPulse Admin',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      home: isLoggedIn
          ? const AdminShell()
          : AdminLoginScreen(key: const ValueKey('admin_login')),
      onGenerateRoute: (settings) {
        if (settings.name == '/guest') {
          return MaterialPageRoute(builder: (_) {
            _isGuest = true;
            return const AdminShell();
          });
        }
        return null;
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF121214) : const Color(0xFFF5F5F5);
    final surface = dark ? const Color(0xFF1C1C1F) : Colors.white;
    final card = dark ? const Color(0xFF242428) : Colors.white;
    final border = dark ? const Color(0xFF333338) : const Color(0xFFE2E4E9);
    final textPrimary = dark ? const Color(0xFFE4E4E7) : const Color(0xFF1A1A2E);
    final textSecondary = dark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280);
    final textMuted = dark ? const Color(0xFF71717A) : const Color(0xFF9CA3AF);

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: dark
          ? const ColorScheme.dark(primary: AdminColors.primary, secondary: AdminColors.warning, surface: Color(0xFF1C1C1F), error: AdminColors.danger)
          : const ColorScheme.light(primary: AdminColors.primary, secondary: AdminColors.warning, surface: Colors.white, error: AdminColors.danger),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: surface, surfaceTintColor: Colors.transparent, elevation: 0, centerTitle: false,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        color: card, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius), side: BorderSide(color: border, width: 1)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64, backgroundColor: surface, surfaceTintColor: Colors.transparent,
        indicatorColor: AdminColors.primary.withValues(alpha: 0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return GoogleFonts.inter(fontSize: 11, fontWeight: sel ? FontWeight.w600 : FontWeight.w400, color: sel ? AdminColors.primary : textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(color: sel ? AdminColors.primary : textMuted, size: 22);
        }),
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: textMuted),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: dark ? const Color(0xFF1C1C1F) : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: const BorderSide(color: AdminColors.primary, width: 1.5)),
        labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary, foregroundColor: Colors.white, elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      )),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kRadius + 4))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? card : const Color(0xFF1A1A2E),
        contentTextStyle: GoogleFonts.inter(color: dark ? textPrimary : Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    );
  }
}
