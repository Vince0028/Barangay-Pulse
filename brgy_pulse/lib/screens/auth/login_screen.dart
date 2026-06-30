import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/supabase_service.dart';
import '../app_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _isRegister = false;
  final _nameController = TextEditingController();
  String _selectedZone = 'Zone 1';
  String? _error;

  final _zones = ['Zone 1', 'Zone 2', 'Zone 3', 'Zone 4', 'Zone 5'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (_isRegister && _nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your full name');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      if (_isRegister) {
        await SupabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          data: {
            'full_name': _nameController.text.trim(),
            'zone': _selectedZone,
            'role': 'civilian',
          },
        );
      } else {
        await SupabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AppShell()),
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
      MaterialPageRoute(builder: (_) => const AppShell()),
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
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                    ),
                    child: const Icon(Icons.location_city_rounded, size: 32, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text('BrgyPulse', style: tt.headlineLarge, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Barangay 183 Community App', style: tt.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: 32),

                Row(
                  children: [
                    _TabButton(label: 'Sign In', selected: !_isRegister,
                        onTap: () => setState(() { _isRegister = false; _error = null; })),
                    const SizedBox(width: 8),
                    _TabButton(label: 'Register', selected: _isRegister,
                        onTap: () => setState(() { _isRegister = true; _error = null; })),
                  ],
                ),
                const SizedBox(height: 20),

                if (_isRegister) ...[
                  TextField(
                    controller: _nameController,
                    style: tt.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    style: tt.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Zone',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                    ),
                    items: _zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                    onChanged: (v) => setState(() => _selectedZone = v ?? 'Zone 1'),
                  ),
                  const SizedBox(height: 10),
                ],

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: tt.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_error!, style: tt.bodySmall?.copyWith(color: AppColors.danger))),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleAuth,
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isRegister ? 'Create Account' : 'Sign In'),
                  ),
                ),

                const SizedBox(height: 16),
                if (!SupabaseService.isConfigured)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.r),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Supabase not configured. Using demo mode.',
                            style: tt.bodySmall?.copyWith(color: AppColors.warning))),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: _continueAsGuest,
                  child: Text('Continue as Guest', style: tt.bodyMedium?.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.r),
            border: Border.all(
              color: selected ? AppColors.primary.withValues(alpha: 0.3) : context.border,
            ),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? AppColors.primary : context.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              )),
        ),
      ),
    );
  }
}
