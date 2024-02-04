import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _usernameController;

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  DateTime? birthday;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
    _animationController?.forward();

    _nameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _usernameController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    var userInfo = await _databaseService.getUserData(user!.uid);
    if (userInfo.exists) {
      var userData = userInfo.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneNumberController.text = userData['phoneNumber'] ?? '';
        _usernameController.text = userData['username'] ?? '';
        birthday = userData['birthday'] != null
            ? DateTime.tryParse(userData['birthday'])
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Edit Profile'),
      body: FadeTransition(
        opacity: _opacityAnimation!,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                LuxuryTextField(
                  hintText: 'Name',
                  controller: _nameController,
                  onChanged: (val) {}, // No need to update state on change here
                  validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
                ),
                LuxuryTextField(
                  hintText: 'Phone Number',
                  controller: _phoneNumberController,
                  onChanged: (val) {}, // No need to update state on change here
                  validator: (val) => val!.isEmpty ? 'Please enter a phone number' : null,
                ),
                LuxuryTextField(
                  hintText: 'Username',
                  controller: _usernameController,
                  onChanged: (val) {}, // No need to update state on change here
                  validator: (val) => val!.isEmpty ? 'Please enter a username' : null,
                ),
                ListTile(
                  title: Text(
                      'Birthday: ${birthday?.toLocal().toString().split(' ')[0] ?? 'Not set'}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: birthday ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != birthday) {
                      setState(() {
                        birthday = picked;
                      });
                    }
                  },
                ),
                LuxuryButton(
                  label: 'Save Changes',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _databaseService.updateUserData(user!.uid, {
                        'name': _nameController.text, // Use controller's text
                        'phoneNumber': _phoneNumberController.text,
                        'username': _usernameController.text,
                        'birthday': birthday?.toIso8601String(),
                      });
                      Navigator.pop(context); // Return to the previous screen after updating
                    }
                  },
                ),              ],
            ),
          ),
        ),
      ),
    );
  }
}
