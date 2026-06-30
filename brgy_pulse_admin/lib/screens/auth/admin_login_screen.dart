import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import '../admin_shell.dart';
import 'admin_register_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await SupabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('AuthException:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueAsGuest() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(kRadius),
                    ),
                    child: Icon(Icons.admin_panel_settings_rounded, size: 32, color: AdminColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text('BrgyPulse Admin', style: tt.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Barangay 183 Officials Portal', style: tt.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: tt.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Official Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: tt.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, size: 18),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: AdminColors.danger.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, size: 14, color: AdminColors.danger),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_error!, style: tt.bodySmall?.copyWith(color: AdminColors.danger))),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleLogin,
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In'),
                  ),
                ),

                const SizedBox(height: 16),
                if (!SupabaseService.isConfigured)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: AdminColors.warning.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AdminColors.warning),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Supabase not configured. Using demo mode.',
                            style: tt.bodySmall?.copyWith(color: AdminColors.warning))),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRegisterScreen()));
                  },
                  child: Text('Create an official account', style: tt.bodyMedium?.copyWith(color: AdminColors.primary)),
                ),

                TextButton(
                  onPressed: _continueAsGuest,
                  child: Text('Continue as Demo Officer', style: tt.bodyMedium?.copyWith(color: context.textSecondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
