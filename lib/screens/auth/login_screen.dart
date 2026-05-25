import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Erreur de connexion')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icon/icon.png', width: 80, height: 80, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 80, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  const Text('MrTube', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Connectez-vous pour continuer', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', hintText: 'votre@email.com'),
                    validator: (v) => v == null || v.isEmpty ? 'Email requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Mot de passe requis' : null,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _onLogin,
                        child: auth.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Se connecter'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Pas de compte ? Créez-en un', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
