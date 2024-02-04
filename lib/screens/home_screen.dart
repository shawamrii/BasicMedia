import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../themedata/theme.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(
        title: 'Home',
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle, color: LuxuryTheme.gold),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: Icon(Icons.contact_mail, color: LuxuryTheme.gold),
            onPressed: () => Navigator.pushNamed(context, '/contact_us'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: LuxuryTheme.gold),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts found'));
          }
          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            // Inside your ListView.builder:
            itemBuilder: (context, index) {
              var postSnapshot = snapshot.data!.docs[index];
              var postData = postSnapshot.data() as Map<String, dynamic>;
              String username = postData.containsKey('username') ? postData['username'] as String : 'Unknown User';

              return PostCard(
                post: postSnapshot,
                username: username,
              );
            },

          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: LuxuryTheme.gold,
        onPressed: () => Navigator.pushNamed(context, '/new_post'),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        );
      },
    );
  }
}
