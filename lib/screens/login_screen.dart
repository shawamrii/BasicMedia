import 'package:flutter/material.dart';
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
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();
  late final Animation<double> _fade =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeIn,
  ));

  String identifier = '';
  String password = '';
  String error = '';

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────── UI
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
            child: ListView(
              children: [
                LuxuryTextField(
                  hintText: 'E-Mail oder Username',
                  controller: _idCtrl,
                  onChanged: (v) => identifier = v.trim(),
                ),
                const SizedBox(height: 20),
                LuxuryTextField(
                  hintText: 'Passwort',
                  controller: _pwCtrl,
                  obscureText: true,
                  onChanged: (v) => password = v,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotDialog,
                    child: const Text('Passwort vergessen?'),
                  ),
                ),
                const SizedBox(height: 10),
                LuxuryButton(
                  label: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) await _login();
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

  // ───────────────────────────────────── Login mit Verifikations-Check
  Future<void> _login() async {
    setState(() => error = '');
    final user =
        await _auth.signIn(identifier: identifier, password: password);

    if (user != null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => error = 'Anmeldung fehlgeschlagen.');
    }
  }

  // ───────────────────────────────────── Passwort-Reset Dialog
  void _showForgotDialog() {
    String input = identifier; // vorbefüllt, falls schon eingegeben
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Passwort zurücksetzen'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'E-Mail oder Username',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(text: input),
          onChanged: (v) => input = v.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success =
                  await _auth.sendPasswordReset(identifier: input);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Passwort-Reset-E-Mail gesendet.'
                        : 'Zurücksetzen fehlgeschlagen.',
                  ),
                ),
              );
            },
            child: const Text('E-Mail senden'),
          ),
        ],
      ),
    );
  }
}
