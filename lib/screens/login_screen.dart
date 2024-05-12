import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/phone_number_verification_screen.dart';
import 'package:chat_app/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                try {
                  // Sign in with email and password
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );

                  // Check if the user has a phone number linked
                  if (userCredential.user != null && (userCredential.user!.phoneNumber == null || userCredential.user!.phoneNumber!.isEmpty)) {
                    // Redirect to phone number verification screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PhoneNumberVerificationScreen(user: userCredential.user!)),
                    );
                  } else {
                    // Redirect to home screen if phone number is already linked
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen(
                        currentUserId: FirebaseAuth.instance.currentUser!.uid,
                      )),
                    );
                  }
                } catch (e) {
                  print(e);  // Handle login error
                  // Show error message
                }

                // try {
                //   // Attempt to sign in.
                //   await FirebaseAuth.instance.signInWithEmailAndPassword(
                //     email: _emailController.text.trim(),
                //     password: _passwordController.text.trim(),
                //   );
                //   Navigator.of(context).pushReplacement(
                //     MaterialPageRoute(
                //       builder: (context) => ChatScreen(
                //         currentUserId: FirebaseAuth.instance.currentUser!.uid,
                //       ),
                //     ),
                //   );
                // } catch (e) {
                //   print(e);
                //   showDialog(
                //     context: context,
                //     builder: (ctx) => AlertDialog(
                //       title: Text("Login Failed"),
                //       content: Text(e.toString()),  // For a production app, you might want to display a more user-friendly message
                //       actions: <Widget>[
                //         TextButton(
                //           onPressed: () {
                //             Navigator.of(ctx).pop();  // Dismiss the dialog
                //           },
                //           child: Text('Okay'),
                //         ),
                //       ],
                //     ),
                //   );
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
}
