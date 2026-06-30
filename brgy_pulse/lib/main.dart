import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'services/supabase_service.dart';
import 'screens/app_shell.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: BrgyPulseApp(),
    ),
  );
}

class BrgyPulseApp extends StatefulWidget {
  const BrgyPulseApp({super.key});

  @override
  State<BrgyPulseApp> createState() => _BrgyPulseAppState();
}

class _BrgyPulseAppState extends State<BrgyPulseApp> {
  bool _isGuest = false;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = SupabaseService.isLoggedIn || _isGuest || !SupabaseService.isConfigured;

    return MaterialApp(
      title: 'BrgyPulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: isLoggedIn
          ? const AppShell()
          : LoginScreen(
              key: const ValueKey('login'),
            ),
      onGenerateRoute: (settings) {
        // Handle guest navigation
        if (settings.name == '/guest') {
          return MaterialPageRoute(builder: (_) {
            _isGuest = true;
            return const AppShell();
          });
        }
        return null;
      },
    );
  }
}
