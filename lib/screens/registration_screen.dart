// registration_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  // Controller
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _userCtrl = TextEditingController();

  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();
  late final Animation<double> _fade =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeIn,
  ));

  DateTime? birthday;
  String error = '';

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _userCtrl.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────── UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuxuryAppBar(title: 'Sign Up'),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: FadeTransition(
          opacity: _fade,
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                LuxuryTextField(
                  hintText: 'E-Mail',
                  controller: _emailCtrl,
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Ungültige E-Mail',
                ),
                LuxuryTextField(
                  hintText: 'Passwort (min 6 Zeichen)',
                  controller: _pwCtrl,
                  obscureText: true,
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Zu kurz',
                ),
                LuxuryTextField(
                  hintText: 'Name',
                  controller: _nameCtrl,
                  validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null,
                ),
                LuxuryTextField(
                  hintText: 'Telefon',
                  controller: _phoneCtrl,
                ),
                LuxuryTextField(
                  hintText: 'Username',
                  controller: _userCtrl,
                  validator: (v) => v!.isEmpty ? 'Pflichtfeld' : null,
                ),
                LuxuryButton(
                  label: birthday == null
                      ? 'Geburtsdatum wählen'
                      : 'Geburtsdatum: '
                          '${birthday!.day}.${birthday!.month}.${birthday!.year}',
                  onPressed: () => _pickDate(context),
                ),
                const SizedBox(height: 10),
                LuxuryButton(
                  label: 'Registrieren',
                  onPressed: _register,
                ),
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────── DATE PICK
  Future<void> _pickDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: birthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => birthday = picked);
  }

  // ────────────────────────────────────────────────────────── REGISTER
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _userCtrl.text.trim();

    // 1) Prüfen, ob Username schon existiert
    if (await _db.usernameExists(username)) {
      setState(() => error = 'Username bereits vergeben');
      return;
    }

    // 2) Firebase-Auth + Firestore
    final user = await _auth.registerWithEmailAndPassword(
      email: _emailCtrl.text.trim(),
      password: _pwCtrl.text,
      username: username,
    );

    if (user is User) {
      await _db.addUserData(user.uid, {
        'name': _nameCtrl.text,
        'phoneNumber': _phoneCtrl.text,
        'username': username,
        'birthday': birthday?.toIso8601String(),
      });

      // 3) Info-Dialog → Verifizierungs-Mail
      _showVerifyDialog();
    } else {
      setState(() => error = 'Registrierung fehlgeschlagen.');
    }
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read, color: Colors.indigo),
            SizedBox(width: 8),
            Text('E-Mail bestätigen'),
          ],
        ),
        content: const Text(
          'Wir haben dir eine Verifizierungs-Mail geschickt.\n'
          'Bitte bestätige sie, bevor du dich einloggst.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
            child: const Text('Zum Login'),
          ),
        ],
      ),
    );
  }
}
