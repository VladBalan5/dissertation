import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:chat_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'RO');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email Address"),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Username"),
                validator: (value) {
                  if (value == null || value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  errorMaxLines: 3,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password cannot be empty';
                  } else if (!RegExp(
                          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{12,}$')
                      .hasMatch(value)) {
                    return 'Password must be at least 12 characters long and include at least one lower case letter, one upper case letter, one number, and one symbol';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  phoneNumber = number;
                  print("lala $phoneNumber");
                },
                onInputValidated: (bool value) {
                  print("lala2 ${value}");
                },
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.DIALOG,
                ),
                ignoreBlank: false,
                // autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: phoneNumber,
                textFieldController: _phoneController,
                formatInput: false,
                keyboardType: TextInputType.number,
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerUser(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        phoneNumber.phoneNumber!,
                        _usernameController.text.trim(),
                        context);
                  }
                },
                child: Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerUser(String email, String password, String phoneNumber,
      String userName, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      String defaultProfilePic = "https://static.vecteezy.com/system/resources/thumbnails/003/337/584/small/default-avatar-photo-placeholder-profile-icon-vector.jpg";
      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        // Save user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'phoneNumber': phoneNumber,
          'profilePicUrl': defaultProfilePic,
          'userName': userName,
          'userId': user.uid,
        });
        await showVerificationEmailSentDialog(context, user);
      }
    } catch (e) {
      print("Error creating user: $e");
      _showErrorDialog(e.toString(), context);
    }
  }

  Future<void> showVerificationEmailSentDialog(BuildContext context, User user) async {
    showDialog(
      context: context,
      barrierDismissible: true,  // Allow dismissing the dialog by tapping outside of it
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verify Your Email'),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SingleChildScrollView(  // Use SingleChildScrollView for long contents
          child: ListBody(
            children: <Widget>[
              Text("A verification email has been sent to your email address. Please verify your email to continue."),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Resend Email'),
            onPressed: () async {
              await user.sendEmailVerification();
              Navigator.of(ctx).pop();  // Close the dialog
              showVerificationEmailSentDialog(context, user);  // Reopen the dialog to show updated status
            },
          ),
          TextButton(
            child: Text('I Verified'),
            onPressed: () async {
              print("lala3");
              await user.reload();  // Reload the user to update the emailVerified status
              User? updatedUser = FirebaseAuth.instance.currentUser;  // Get the latest instance of the user
              print("Updated email verified status: ${updatedUser!.emailVerified}");

              if (updatedUser.emailVerified) {
                Navigator.of(ctx).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
                _showSuccessDialog(context);
              } else {
                Navigator.of(ctx).pop();
                Navigator.of(ctx).pop();
                _showErrorDialog("Please verify your email first.", context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,  // This allows the dialog to close when tapping outside
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Registration Error'),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SingleChildScrollView( // Ensures the dialog handles overflow
          child: Text(message),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,  // This allows the dialog to close when tapping outside
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Account Created'),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text('Your account was created with success. You can login now.'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
