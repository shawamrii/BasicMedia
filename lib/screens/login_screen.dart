import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  String email = '';
  String password = '';
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
      appBar: LuxuryAppBar(title: 'Login'), // Updated to LuxuryAppBar
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: FadeTransition(
          opacity: _opacityAnimation!,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                LuxuryTextField( // Updated to LuxuryTextField
                  hintText: 'Email',
                  controller: _emailController,
                  onChanged: (val) => setState(() => email = val.trim()),
                ),
                SizedBox(height: 20.0),
                LuxuryTextField( // Updated to LuxuryTextField
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (val) => setState(() => password = val),
                ),
                SizedBox(height: 20.0),
                LuxuryButton( // Updated to LuxuryButton
                  label: 'Login',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _loginUser();
                    }
                  },
                ),
                SizedBox(height: 12.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                LuxuryButton( // Updated to LuxuryButton
                  label: 'Register',
                  onPressed: () {
                    Navigator.pushNamed(context, '/register'); // Navigate to the registration screen
                  },
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

bool _isEmail(String input) {
    return input.contains('@');
  }

  // Method to handle user login
  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      String loginInput = email; // This can be either email or username

      if (!_isEmail(loginInput)) {
        // If input is username, retrieve the associated email
        String? emailFromUsername = await _authService.getEmailFromUsername(loginInput);
        if (emailFromUsername != null) {
          loginInput = emailFromUsername;
        } else {
          setState(() => error = 'Username not found');
          return;
        }
      }

      dynamic result = await _authService.signInWithEmailAndPassword(loginInput, password);
      if (result is User) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home screen on successful login
      } else {
        // Login failed, show error
        setState(() => error = 'Failed to sign in');
      }
    }
  }
}
