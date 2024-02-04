import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  // Instantiate the text editing controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  String email = '';
  String password = '';
  String name = '';
  String phoneNumber = '';
  String username = '';
  DateTime? birthday;
  String error = '';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Sign Up'), // Updated to LuxuryAppBar
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: FadeTransition(
          opacity: _opacityAnimation!,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  LuxuryTextField( // Updated to LuxuryTextField
                    hintText: 'Email',
                    controller: _emailController,
                    onChanged: (val) => setState(() => email = val.trim()),
                  ),
                  LuxuryTextField( // Updated to LuxuryTextField
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (val) => setState(() => password = val),
                  ),
                  LuxuryTextField( // Updated to LuxuryTextField
                    hintText: 'Name',
                    controller: _nameController,
                    onChanged: (val) => setState(() => name = val),
                  ),
                  LuxuryTextField( // Updated to LuxuryTextField
                    hintText: 'Phone Number',
                    controller: _phoneNumberController,
                    onChanged: (val) => setState(() => phoneNumber = val),
                  ),
                  LuxuryTextField( // Updated to LuxuryTextField
                    hintText: 'Username',
                    controller: _usernameController,
                    onChanged: (val) => setState(() => username = val),
                  ),
                  LuxuryButton( // Updated to LuxuryButton
                    label: 'Select Birthday',
                    onPressed: () => _selectDate(context),
                  ),
                  LuxuryButton( // Updated to LuxuryButton
                    label: 'Register',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _registerUser();
                      }
                    },
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


Future<void> _selectDate(BuildContext context) async {
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
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      dynamic result = await _authService.registerWithEmailAndPassword(email, password);
      if (result is User) {
        await _databaseService.addUserData(result.uid, {
          'name': name,
          'phoneNumber': phoneNumber,
          'username': username,
          'birthday': birthday?.toIso8601String(),
        });

        await result.sendEmailVerification();
        Navigator.pop(context); // Navigate back to the login screen
      } else {
        setState(() => error = result ?? 'Registration failed');
      }
    }
  }
}
