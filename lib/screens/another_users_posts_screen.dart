import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../themedata/theme.dart';
import 'package:intl/intl.dart';

class AnotherPostsScreen extends StatelessWidget {
  final String userId;
  final DatabaseService _databaseService = DatabaseService();

  AnotherPostsScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Posts'), // Using LuxuryAppBar
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts found', style: TextStyle(color: LuxuryTheme.dark)));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot post = snapshot.data!.docs[index];
              return _buildPostItem(context, post);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, DocumentSnapshot post) {
    DateTime postDate = (post['timestamp'] as Timestamp).toDate();
    String formattedDate = DateFormat('MMM dd, yyyy hh:mm a').format(postDate);
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['content'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 8), // Space between content and timestamp
            Text(formattedDate, style: TextStyle(color: Colors.grey, fontSize: 12)),// Customize as needed
          ],
        ),
      ),
    );
  }
}
