import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  // Get user by username
  Future<String?> getEmailFromUsername(String username) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').where('username', isEqualTo: username).get();
      if (snapshot.docs.isNotEmpty) {
        var userDoc = snapshot.docs.first.data();
        return userDoc is Map<String, dynamic> ? userDoc['email'] as String? : null;
      }
      return null;
    } catch (error) {
      print(error);
      return null;
    }
  }}
