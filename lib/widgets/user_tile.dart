import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/profile_screen.dart';
import '../themedata/theme.dart';

class UserTile extends StatelessWidget {
  final DocumentSnapshot userSnapshot;

  UserTile({required this.userSnapshot});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
    String userId = userSnapshot.id;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: userId),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          // Optionally, replace with a more sophisticated widget or an image
          backgroundColor: LuxuryTheme.gold, // Updated color
          child: Text(
            userData['username'][0].toUpperCase(),
            style: TextStyle(color: LuxuryTheme.dark), // Updated text color
          ),
        ),
        title: Text(
          userData['username'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: LuxuryTheme.dark, // Updated color
          ),
        ),
        subtitle: Text(
          userData['name'],
          style: TextStyle(color: LuxuryTheme.silver), // Updated color
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: LuxuryTheme.gold, // Updated color
        ),
      ),
    );
  }
}
