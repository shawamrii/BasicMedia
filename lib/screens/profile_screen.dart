import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/image_upload_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import 'my_posts_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
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
            _infoRow('Email', user?.email ?? 'Not set'),
            _infoRow('Phone', userData['phoneNumber'] ?? 'Not set'),
            _infoRow('Username', userData['username'] ?? 'Not set'),
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
/*  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Profile'), // Updated to LuxuryAppBar
      body: FadeTransition(
        opacity: _opacityAnimation!,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              userData.containsKey('profilePicture')
                  ? Image.network(userData['profilePicture'], width: 100, height: 100)
                  : Placeholder(fallbackHeight: 100, fallbackWidth: 100),
              Text('Name: ${userData['name'] ?? 'Not set'}'),
              Text('Email: ${user?.email ?? 'Not set'}'),
              Text('Phone: ${userData['phoneNumber'] ?? 'Not set'}'),
              Text('Username: ${userData['username'] ?? 'Not set'}'),
              SizedBox(height: 20),
              LuxuryButton( // Updated to LuxuryButton
                label: 'Upload Profile Picture',
                onPressed: () async {
                  String? imageUrl = await _imageUploadService.uploadImage();
                  if (imageUrl != null) {
                    await _databaseService.updateUserData(user!.uid, {
                      'profilePicture': imageUrl,
                    });
                    setState(() {
                      userData['profilePicture'] = imageUrl;
                    });
                  }
                },
              ),
              LuxuryButton( // Updated to LuxuryButton
                label: 'Edit Profile',
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile', arguments: user!.uid);
                },
              ),
              LuxuryButton( // Updated to LuxuryButton
                label: 'Delete Account',
                onPressed: () => _confirmAccountDeletion(context),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  void _confirmAccountDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Account Deletion'),
        content: Text('Are you sure you want to delete your account? This action is irreversible.'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteUserAccount();
            },
          ),
        ],
      ),
    );
  }
  Widget _buildProfileActions() {
    return Column(
      children: [
        LuxuryButton(
          label: 'Upload Profile Picture',
          onPressed: () async {
            String? imageUrl = await _imageUploadService.uploadImage();
            if (imageUrl != null) {
              await _databaseService.updateUserData(user!.uid, {
                'profilePicture': imageUrl,
              });
              setState(() {
                userData['profilePicture'] = imageUrl;
              });
            }
          },
        ),
        const SizedBox(height: 10),
        LuxuryButton(
          label: 'Edit Profile',
          onPressed: () {
            Navigator.pushNamed(context, '/edit_profile', arguments: user!.uid);
          },
        ),
        SizedBox(height: 10),
        LuxuryButton(
          label: 'My Posts',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPostsScreen(userId: user!.uid)),
            );
          },
        ),
        const SizedBox(height: 10),
        LuxuryButton(
          label: 'Delete Account',
          onPressed: () => _confirmAccountDeletion(context),
          color: Colors.red,
        ),

      ],
    );
  }




Future<void> _deleteUserAccount() async {
    // Delete user data from Firestore
    await _databaseService.deleteUserData(user!.uid);

    // Delete user authentication record
    await user!.delete();

    // Redirect to login or welcome screen after deletion
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
