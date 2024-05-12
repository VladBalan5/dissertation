import 'package:chat_app/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create account")),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email Address"),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: "Phone Number"),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            // TextFormField(
            //   controller: _phoneNumberController,
            //   decoration: InputDecoration(labelText: 'Phone Number'),
            //   keyboardType: TextInputType.phone,
            //   inputFormatters: [
            //     FilteringTextInputFormatter.digitsOnly,  // Only allows digits to be entered
            //     // You can add more formatters here to format the input as phone number
            //   ],
            //   validator: (value) {
            //     if (value!.isEmpty || value.length != 10) {
            //       return 'Enter a valid phone number';
            //     }
            //     return null;
            //   },
            // ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                registerUser(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _phoneNumberController.text,
                    _usernameController.text,
                    context);
              },
              // onPressed: () async {
              //   await FirebaseAuth.instance.createUserWithEmailAndPassword(
              //     email: _emailController.text.trim(),
              //     password: _passwordController.text.trim(),
              //   );
              //   Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(
              //       builder: (context) => LoginScreen(),
              //     ),
              //   );
              // },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser(String email, String password, String phoneNumber,
      String userName, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String defaultPicUrl = "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg";

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is really created and retrieved
      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'phoneNumber': phoneNumber,
          'profilePicUrl': defaultPicUrl,
          'userName': userName,
          'userId': user.uid,
          // Add other necessary fields
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else {
        print("User object not returned.");
      }
    } catch (e) {
      print("Error creating user: $e");
      _showErrorDialog("Failed to register. Error: $e", context);
    }
  }

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registration Failed'),
        content: Text(message),
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
