import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // ─────────────────────────────────────────────────────────────────────
  //  Firebase Instanzen
  // ─────────────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────────────
  //  REGISTRIERUNG
  // ─────────────────────────────────────────────────────────────────────
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Firebase-Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      if (user != null) {
        // Benutzer‐Datensatz in Firestore
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Verifizierungs-E-Mail
        if (!user.emailVerified) await user.sendEmailVerification();

        return user;
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ANMELDUNG  (E-Mail ODER Username)
  // ─────────────────────────────────────────────────────────────────────
  Future<User?> signIn({
    required String identifier, // email ODER username
    required String password,
  }) async {
    try {
      String email = identifier;

      // Falls kein '@' enthalten → als Username interpretieren
      if (!identifier.contains('@')) {
        final found = await _getEmailFromUsername(identifier.trim());
        if (found == null) throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Kein Benutzer mit diesem Benutzernamen.',
        );
        email = found;
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;

      if (user != null && !user.emailVerified) {
        // Nicht verifiziert → sofort signOut und Fehler werfen
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'E-Mail noch nicht bestätigt.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('SignIn error: ${e.code}');
      return null;
    } catch (e) {
      print('SignIn error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  //  VERIFIZIERUNGS-MAIL ERNEUT SENDEN
  // ─────────────────────────────────────────────────────────────────────
  Future<bool> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        return true;
      } catch (e) {
        print('Resend verification error: $e');
      }
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────
  //  USER SIGN-OUT
  // ─────────────────────────────────────────────────────────────────────
  Future<void> signOut() async => _auth.signOut();

  // ─────────────────────────────────────────────────────────────────────
  //  PRIVATE HILFSFUNKTION: Username → E-Mail
  // ─────────────────────────────────────────────────────────────────────
  Future<String?> _getEmailFromUsername(String username) async {
    try {
      final snap = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        return snap.docs.first.data()['email'] as String?;
      }
      return null;
    } catch (e) {
      print('getEmailFromUsername error: $e');
      return null;
    }
  }
}
