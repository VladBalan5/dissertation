import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final User user;
  final String phoneNumber;

  PhoneVerificationScreen({Key? key, required this.user, required this.phoneNumber}) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _smsController = TextEditingController();
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber.isNotEmpty) {
      _verifyPhoneNumber(widget.phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Phone Number"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _smsController,
              decoration: InputDecoration(
                labelText: "Enter Verification Code",
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _signInWithPhoneNumber(),
            child: Text("Verify"),
          ),
        ],
      ),
    );
  }

  void _verifyPhoneNumber(String phoneNumber) {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await widget.user.linkWithCredential(credential);
        Navigator.pop(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text,
      );

      await widget.user.linkWithCredential(credential);
      // Navigate to home or another appropriate screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              currentUserId: widget.user.uid,
            ),
          ),
        );
      // Navigator.of(context).popUntil((route) => route.isFirst);
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Failed to sign in: ${e.toString()}");
    }
  }
}
