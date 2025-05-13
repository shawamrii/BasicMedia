// database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ────────────────────────────────────────────────────────────────
  //  USER   CRUD
  // ────────────────────────────────────────────────────────────────
  Future<void> addUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> deleteUserData(String uid) async {
    // 1) User‑Dokument löschen
    await _db.collection('users').doc(uid).delete();

    // 2) Alle Posts dieses Users entfernen (inkl. Comments)
    final posts = await _db.collection('posts').where('userId', isEqualTo: uid).get();
    for (final doc in posts.docs) {
      await deletePost(doc.id);
    }
  }

  // Prüft, ob ein Username schon existiert
  Future<bool> usernameExists(String username) async {
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // Optional – liefert E‑Mail zu Username (für Password‑Reset o. Ä.)
  Future<String?> getEmailFromUsername(String username) async {
    final snap = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty ? snap.docs.first['email'] as String : null;
  }

  // ────────────────────────────────────────────────────────────────
  //  POSTS  &  COMMENTS
  // ────────────────────────────────────────────────────────────────
  Future<void> addPost(String uid, Map<String, dynamic> postData) async {
    final userSnap = await getUserData(uid);
    final userInfo = userSnap.data();
    final username = userInfo?['username'] ?? 'Unknown';

    await _db.collection('posts').add({
      ...postData,
      'userId': uid,
      'username': username,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePost(String postId) async {
    // 1) Comments löschen
    final comments = await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    for (final c in comments.docs) {
      await c.reference.delete();
    }
    // 2) Post löschen
    await _db.collection('posts').doc(postId).delete();
  }

  // Kommentare hinzufügen / abfragen
  Future<void> addComment(String postId, Map<String, dynamic> data) async {
    await _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String postId) {
    return _db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }

  // Streams für Posts
  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserPosts(String uid) {
    return _db.collection('posts').where('userId', isEqualTo: uid).snapshots();
  }
}
