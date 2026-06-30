import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import 'admin_login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await SupabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'role': 'admin', // The trigger might override, but we will fix trigger or they can be made admin
        },
      );
      if (mounted) {
        setState(() => _success = true);
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('Database error') || msg.contains('already registered') || msg.contains('unique')) {
        setState(() => _error = 'This email already has an account. Please sign in instead.');
      } else {
        setState(() => _error = msg.replaceAll('AuthException:', '').trim());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_outlined, size: 64, color: AdminColors.primary),
                const SizedBox(height: 24),
                Text('Admin Sign Up', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Create an official account', style: tt.bodyMedium?.copyWith(color: context.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: 32),

                if (_success) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AdminColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(kRadius),
                      border: Border.all(color: AdminColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: AdminColors.success, size: 32),
                        const SizedBox(height: 12),
                        Text('Account created successfully!', style: tt.bodyMedium?.copyWith(color: AdminColors.success, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Please check your email to confirm your account.', style: tt.bodySmall?.copyWith(color: AdminColors.success), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen())),
                      child: const Text('Back to Sign In'),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Juan Dela Cruz',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: context.cardFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'admin@barangay.gov.ph',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: context.cardFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: context.cardFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 8),

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
                      onPressed: _loading ? null : _handleRegister,
                      child: _loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create Account'),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLoginScreen()));
                    },
                    child: Text('Already have an account? Sign In', style: tt.bodyMedium?.copyWith(color: AdminColors.primary)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
