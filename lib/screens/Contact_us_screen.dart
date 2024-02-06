import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser; // Moved user here



  Future<void> _submitForm() async {
    // This assumes _fetchUserEmail has already been called and userEmail is set
    final String emailBody = 'Name: ${_nameController.text}\n'
        'Message: ${_messageController.text}';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: "m1.shawamreh@gmail.com", // The user's email you fetched
      query: encodeQueryParameters(<String, String>{
        'subject': _subjectController.text,
        'body': emailBody,
      }),
    );

    // Use url_launcher to launch the email app
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      _showErrorDialog('Could not launch email app.');
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            LuxuryButton(
              label:"Close",
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LuxuryAppBar(title: 'Contact Us'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LuxuryTextField(
              hintText: 'Your Name',
              controller: _nameController,
            ),
            SizedBox(height: 10),
            LuxuryTextField(
              hintText: 'Subject',
              controller: _subjectController,
            ),
            SizedBox(height: 10),
            LuxuryTextField(
              hintText: 'Your Message',
              controller: _messageController,
              obscureText: false,
              maxLines: 5,  // Allow multiple lines
              minLines: 3,  // Set a minimum height
              onChanged: (val) {
                // Handle change if needed
              },
            ),
            SizedBox(height: 20),
            LuxuryButton(
              label: 'Submit',
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }
}
