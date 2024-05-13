// import 'package:chat_app/screens/chat_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class PhoneVerificationScreen extends StatefulWidget {
//   final User user;
//   final String phoneNumber;
//
//   PhoneVerificationScreen({Key? key, required this.user, required this.phoneNumber}) : super(key: key);
//
//   @override
//   _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
// }
//
// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   final TextEditingController _smsController = TextEditingController();
//   String? _verificationId;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.phoneNumber.isNotEmpty) {
//       _verifyPhoneNumber(widget.phoneNumber);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Verify Phone Number"),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _smsController,
//               decoration: InputDecoration(
//                 labelText: "Enter Verification Code",
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => _signInWithPhoneNumber(),
//             child: Text("Verify"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _verifyPhoneNumber(String phoneNumber) {
//     FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       timeout: Duration(seconds: 60),
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await widget.user.linkWithCredential(credential);
//         Navigator.pop(context);
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         print("Verification failed: ${e.message}");
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         _verificationId = verificationId;
//       },
//     );
//   }
//
//   void _signInWithPhoneNumber() async {
//     try {
//       final AuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: _smsController.text,
//       );
//
//       await widget.user.linkWithCredential(credential);
//       // Navigate to home or another appropriate screen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (context) => ChatScreen(
//               currentUserId: widget.user.uid,
//             ),
//           ),
//         );
//       // Navigator.of(context).popUntil((route) => route.isFirst);
//       // Navigator.pushReplacementNamed(context, '/home');
//     } catch (e) {
//       print("Failed to sign in: ${e.toString()}");
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Assuming you have a HomeScreen where you want to redirect after verification

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final User user;

  PhoneVerificationScreen({Key? key, required this.phoneNumber, required this.user}) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _smsController = TextEditingController();
  String _verificationId = "";

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  Future<void> _verifyPhoneNumber() async {
    final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("lala11 ${widget.user.uid}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: widget.user.uid,)));
    };

    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed. Error: ${e.message}")),
      );
    };

    final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
      setState(() {
        _verificationId = verificationId;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60), // Adjust the timeout as needed
    );
  }

  Future<void> _submitSmsCode() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text.trim(),
      );

      final User? user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if (user != null) {
        print("lala12 ${user.uid}");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: user.uid)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to verify SMS code: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Phone'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Enter the code sent to ${widget.phoneNumber}"),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(labelText: 'SMS Code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSmsCode,
              child: Text('Verify'),
            )
          ],
        ),
      ),
    );
  }
}
