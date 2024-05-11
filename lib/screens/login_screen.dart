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
                // await FirebaseAuth.instance.signInWithEmailAndPassword(
                //   email: _emailController.text.trim(),
                //   password: _passwordController.text.trim(),
                // );
                Navigator.pushReplacementNamed(context, '/chat');
              },
              child: Text("Login"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // await FirebaseAuth.instance.signInWithEmailAndPassword(
                //   email: _emailController.text.trim(),
                //   password: _passwordController.text.trim(),
                // );
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}
