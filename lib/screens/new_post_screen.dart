import 'dart:html';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/image_upload_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';


class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser; // Moved user here
  String postContent = '';
  String? username; // Variable to hold the username
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      var userInfoSnapshot = await _databaseService.getUserData(user!.uid);
      var userInfo = userInfoSnapshot.data();

      if (userInfo is Map<String, dynamic>) {
        setState(() {
          username = userInfo['username'] as String? ?? user!.email; // Fallback to email if username is not set
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'New Post'), // Updated to LuxuryAppBar
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              LuxuryTextField( // Updated to LuxuryTextField
                hintText: 'Post Content',
                controller: _commentController,
                onChanged: (val) => setState(() => postContent = val),
              ),
              LuxuryButton( // Updated to LuxuryButton
                label: 'Post',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => isLoading = true);
                    try {
                      ImageUploadService imageUpload = ImageUploadService();
                      String? imageUrl = await imageUpload.uploadImage();
                      if (imageUrl != null) {
                        await _databaseService.addPost(user!.uid, {
                          'content': postContent,
                          'imageUrl': imageUrl,
                          'username': username,
                        });
                      } else {
                        await _databaseService.addPost(user!.uid, {
                          'content': postContent,
                          'username': username,
                        });
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      // Handle errors or show an error message
                    } finally {
                      setState(() => isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
