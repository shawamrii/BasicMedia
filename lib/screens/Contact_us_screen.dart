import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/LuxuryAppBar.dart';
import '../widgets/LuxuryButton.dart';
import '../widgets/LuxuryTextField.dart';
import '../themedata/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();



  Future<void> _submitForm() async {
    final response = await http.post(
      Uri.parse('http://your-backend-url/sendemail'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'to': _emailController.text,
        'subject': 'Contact From App - ${_nameController.text}',
        'text': 'Name: ${_nameController.text}\nEmail: ${_emailController.text}\nMessage: ${_messageController.text}',
      }),
    );

    if (response.statusCode == 200) {
      // Successfully sent the email
      print('Email sent');
    } else {
      // Failed to send the email
      print('Failed to send email: ${response.body}');
    }

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    Navigator.of(context).pop();
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }


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
              hintText: 'Your Email',
              controller: _emailController,
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
