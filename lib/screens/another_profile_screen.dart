import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/image_upload_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import 'another_users_posts_screen.dart';
import 'my_posts_screen.dart';

class AnotherProfileScreen extends StatefulWidget {
  final String userId;

  AnotherProfileScreen({required this.userId});

  @override
  _AnotherProfileScreenState createState() => _AnotherProfileScreenState();
}

class _AnotherProfileScreenState extends State<AnotherProfileScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData(widget.userId);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
  Future<void> _loadUserData(String userId) async {
    var userInfo = await _databaseService.getUserData(userId);
    if (userInfo.exists) {
      setState(() {
        userData = userInfo.data() as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Profile'),
      body: FadeTransition(
        opacity: _opacityAnimation!,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildProfilePicture(),
              SizedBox(height: 20),
              _buildProfileInfo(),
              SizedBox(height: 20),
              _buildProfileActions(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfilePicture() {
    ImageProvider backgroundImage;
    if (userData.containsKey('profilePicture') && userData['profilePicture'] is String) {
      backgroundImage = NetworkImage(userData['profilePicture'] as String);
    } else {
      backgroundImage =  AssetImage('images/blank.png'); // Placeholder image
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: backgroundImage,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _infoRow('Name', userData['name'] ?? 'Not set'),
            //_infoRow('Email', user?.email ?? 'Not set'),
            //_infoRow('Phone', userData['phoneNumber'] ?? 'Not set'),
            //_infoRow('Username', userData['username'] ?? 'Not set'),
          ],
        ),
      ),
    );
  }
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }


  Widget _buildProfileActions() {
    return Column(
      children: [
//        const SizedBox(height: 10),
        SizedBox(height: 10),
        LuxuryButton(
          label: 'Posts',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnotherPostsScreen(userId: widget.userId)),
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
