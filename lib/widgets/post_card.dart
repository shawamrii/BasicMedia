import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../widgets/LuxuryButton.dart';
import '../themedata/theme.dart';
import 'LuxuryTextField.dart'; // Make sure this path is correct

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot post;
  final String username;

  PostCard({required this.post, required this.username});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
    String postId = post.id;
    String content = postData['content'] ?? 'No Content';
    String imageUrl = postData['imageUrl'] ?? '';
    String username = postData.containsKey('username') ? postData['username'] as String : 'Unknown User';
    DateTime timestamp = (postData['timestamp'] as Timestamp).toDate();
    String formattedTime = DateFormat('MMM dd, yyyy hh:mm a').format(timestamp);
    String profilePictureUrl = postData['profilePicture'] ?? 'images/blank.png';

    return Card(
      elevation: 5.0,
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                if (profilePictureUrl.isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(profilePictureUrl),
                    radius: 16, // Adjust the size to fit your design
                  ),
                SizedBox(width: 8), // Give some space between the avatar and the username
                Text(username, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),            SizedBox(height: 5.0),
            Text(content, style: TextStyle(fontSize: 14)),
            if (imageUrl.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            Text(formattedTime, style: TextStyle(color: Colors.grey, fontSize: 12)),
            Divider(),
            _buildCommentSection(postId, context),
            _buildAddCommentSection(postId),
            _buildShareButton(content, imageUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(String postId, BuildContext context) {
    final DatabaseService _databaseService = DatabaseService();

    return StreamBuilder<QuerySnapshot>(
      stream: _databaseService.getComments(postId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var comment = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(comment['username']),
                subtitle: Text(comment['comment']),
              );
            },
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return SizedBox();
      },
    );
  }

  Widget _buildAddCommentSection(String postId) {
    final TextEditingController _commentController = TextEditingController();
    final DatabaseService _databaseService = DatabaseService();

    return Row(
      children: <Widget>[
        Expanded(
          child: LuxuryTextField( // Assuming LuxuryTextField is similar to TextField
            hintText: 'Write a comment...',
            controller: _commentController,
            minLines: 1,
            maxLines: 1,
            onChanged: (val) {}, // You can remove this if you're not using it
            // If your LuxuryTextField doesn't support validation, remove the validator
            validator: (val) => val != null && val.trim().isEmpty ? 'Comment can\'t be empty' : null,
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_commentController.text.isNotEmpty) {
              _databaseService.addComment(
                postId,
                {
                  'username': FirebaseAuth.instance.currentUser?.displayName ?? 'Anonymous',
                  'comment': _commentController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                },
              );
              _commentController.clear();
            }
          },
        ),
      ],
    );
  }

  Widget _buildShareButton(String content, String imageUrl) {
    return LuxuryButton(
      label: 'Share',
      onPressed: () {
        final text = content + (imageUrl.isNotEmpty ? '\n$imageUrl' : '');
        Share.share(text, subject: 'Check out this post!');
      },
    );
  }
}
