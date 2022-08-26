import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Widget profile() {
  final user = FirebaseAuth.instance.currentUser!;
  return SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Signed in as",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            user.email!,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 40,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(50),
              primary: Colors.red,
            ),
            icon: Icon(Icons.arrow_back, size: 32),
            label: Text(
              "Sign Out",
              style: TextStyle(fontSize: 24),
            ),
            onPressed: () async {
              FirebaseAuth.instance.signOut();
              GoogleSignIn().signOut();
            },
          ),
        ],
      ),
    ),
  );
}
