import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/phone_verification_screen.dart';
import 'package:chat_app/screens/registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool emailVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email Address"),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // checkEmailVerified(context);
                // print("lala6 ${emailVerified}");
                // if (emailVerified) {
                signInWithEmailAndPassword(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  context,
                );
                // }
              },
              child: Text("Login"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(),
                  ),
                );
              },
              child: Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> checkEmailVerified(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    await user?.reload();
    user = _auth.currentUser; // Refresh the user instance

    if (user != null && !user.emailVerified) {
      // User's email is not verified, show the dialog
      showEmailNotVerifiedDialog(context, user);
    } else {
      setState(() {
        emailVerified = true;
      });
    }
  }

  void showEmailNotVerifiedDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text('Email Not Verified'),
        content: Text(
            'Your email has not been verified. Please check your email for the verification link, or resend the verification email.'),
        actions: <Widget>[
          TextButton(
            child: Text('Resend Email'),
            onPressed: () async {
              await user.sendEmailVerification();
              await FirebaseAuth.instance.signOut();
              Navigator.of(ctx).pop(); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Verification email has been resent."),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
          TextButton(
            child: Text('Close'),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assuming the user is logged in now
      User? user = userCredential.user;

      await checkEmailVerified(context);

      if (emailVerified) {
        if (user != null) {
          // Fetch the phone number from Firestore
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(user.uid).get();
          // Cast the data to Map<String, dynamic>
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          String phoneNumber = userData?['phoneNumber'] ?? '';
          if (phoneNumber.isNotEmpty) {
            // Redirect to Phone Verification Screen with the phone number
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PhoneVerificationScreen(
                  user: user,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          } else {
            // Handle case where phone number is not available
            print("Phone number not found in the database.");
          }
        }
      }
    } catch (e) {
      print("Login Error: $e");
      _showLoginError(context, e.toString());
    }
  }

  void _showLoginError(BuildContext context, String errorMsg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(errorMsg),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
