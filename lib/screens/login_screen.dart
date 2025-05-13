// login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();
  late final Animation<double> _fade =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeIn,
  ));

  String emailOrUsername = '';
  String password = '';
  String error = '';

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────
  //   UI
  // ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuxuryAppBar(title: 'Login'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: FadeTransition(
          opacity: _fade,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LuxuryTextField(
                  hintText: 'E-Mail oder Username',
                  controller: _emailController,
                  onChanged: (v) =>
                      setState(() => emailOrUsername = v.trim()),
                ),
                const SizedBox(height: 20),
                LuxuryTextField(
                  hintText: 'Passwort',
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (v) => setState(() => password = v),
                ),
                const SizedBox(height: 20),
                LuxuryButton(
                  label: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _login();
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
                LuxuryButton(
                  label: 'Registrieren',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  //   LOGIN-LOGIK
  // ─────────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    setState(() => error = '');

    final user = await _authService.signIn(
      identifier: emailOrUsername,
      password: password,
    );

    if (user != null) {
      // Erfolg
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Prüfen, ob unverifizierte E-Mail der Grund war
      if (_authService
              .resendVerificationEmail is Function && // safety
          await _authService.resendVerificationEmail()) {
        _showVerifyDialog();
      } else {
        setState(() => error = 'Anmeldung fehlgeschlagen.');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //   Dialog → Verifizierungs-Mail erneut senden
  // ─────────────────────────────────────────────────────────────────────
  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_unread, color: Colors.orange),
            SizedBox(width: 8),
            Text('E-Mail nicht bestätigt'),
          ],
        ),
        content: const Text(
          'Bitte bestätige deine E-Mail-Adresse, ehe du dich einloggst.\n'
          'Wir haben dir gerade eine neue Bestätigungs-Mail geschickt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
