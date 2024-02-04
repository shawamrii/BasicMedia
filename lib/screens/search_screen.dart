import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../themedata/theme.dart'; // Import LuxuryTheme

class UserTile extends StatelessWidget {
  final DocumentSnapshot userSnapshot;

  UserTile({required this.userSnapshot});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/user_profile', arguments: userSnapshot.id);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: LuxuryTheme.gold, // Updated color
              child: Text(
                userData['username'][0].toUpperCase(),
                style: TextStyle(color: LuxuryTheme.dark), // Updated text color
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['username'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: LuxuryTheme.dark, // Updated color
                    ),
                  ),
                  Text(
                    userData['name'],
                    style: TextStyle(
                      fontSize: 16,
                      color: LuxuryTheme.silver, // Updated color
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: LuxuryTheme.gold, // Updated color
            ),
          ],
        ),
      ),
    );
  }
}
