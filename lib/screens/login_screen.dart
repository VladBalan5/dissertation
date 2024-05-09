import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
          TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(SignInRequested(emailController.text, passwordController.text));
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}
