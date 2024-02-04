import 'package:basic_media/screens/Contact_us_screen.dart';
import 'package:basic_media/screens/edit_profile_screen.dart';
import 'package:basic_media/screens/home_screen.dart';
import 'package:basic_media/screens/login_screen.dart';
import 'package:basic_media/screens/new_post_screen.dart';
import 'package:basic_media/screens/profile_screen.dart';
import 'package:basic_media/screens/registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthenticationWrapper(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/home': (context) => HomeScreen(),
        '/new_post': (context) => NewPostScreen(),
        '/profile': (context) => ProfileScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ""),
        '/edit_profile': (context) => EditProfileScreen(),
        '/contact_us': (context) => ContactUsScreen(),


      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Check Firebase Auth state and return either HomeScreen or LoginScreen
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen(); // User is signed in
        }
        return LoginScreen(); // User needs to sign in
      },
    );
  }
}
