import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add new user data
  Future<void> addUserData(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  // Update user data
  Future<void> updateUserData(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).update(userData);
  }

  // Get user data
  Future<DocumentSnapshot> getUserData(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // Add new post
  Future<void> addPost(String userId, Map<String, dynamic> postData) async {
    var userInfoSnapshot = await getUserData(userId);
    var userInfo = userInfoSnapshot.data();

    // Ensure userInfo is cast to Map<String, dynamic>
    if (userInfo is Map<String, dynamic>) {
      var username = userInfo['username'] as String? ?? 'Unknown User';

      await _firestore.collection('posts').add({
        ...postData,
        'userId': userId,
        'username': username, // Include the username
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Handle the case where userInfo is not a Map (or is null)
      // This might involve logging an error or providing a default value
    }
  }
  // Add a comment to a post
  Future<void> addComment(String postId, Map<String, dynamic> commentData) async {
    await _firestore.collection('posts').doc(postId).collection('comments').add(commentData);
  }

  // Get comments for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return _firestore.collection('posts').doc(postId).collection('comments').orderBy('timestamp').snapshots();
  }


  // Get posts with user data
  Stream<QuerySnapshot> getPosts() {
    return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots();
  }

  // Get user's posts
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore.collection('posts').where('userId', isEqualTo: userId).snapshots();
  }

  Future<void> deleteUserData(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    // Also, handle deletion of any related data like posts
  }
  Future<void> deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      // Show a success message or update UI
    } catch (e) {
      // Handle errors, e.g., show an error message
    }
  }



}
