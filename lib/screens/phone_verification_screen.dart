// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_auth/firebase_auth.dart';
// // // // import 'chat_screen.dart'; // Assuming you have a HomeScreen where you want to redirect after verification
// // // //
// // // // class PhoneVerificationScreen extends StatefulWidget {
// // // //   final String phoneNumber;
// // // //   final User user;
// // // //
// // // //   PhoneVerificationScreen({Key? key, required this.phoneNumber, required this.user}) : super(key: key);
// // // //
// // // //   @override
// // // //   _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
// // // // }
// // // //
// // // // class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
// // // //   final _smsController = TextEditingController();
// // // //   String _verificationId = "";
// // // //
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _verifyPhoneNumber();
// // // //   }
// // // //
// // // //   Future<void> _verifyPhoneNumber() async {
// // // //     final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
// // // //       await FirebaseAuth.instance.signInWithCredential(credential);
// // // //       print("lala11 ${widget.user.uid}");
// // // //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: widget.user.uid,)));
// // // //     };
// // // //
// // // //     final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(content: Text("Verification failed. Error: ${e.message}")),
// // // //       );
// // // //     };
// // // //
// // // //     final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
// // // //       setState(() {
// // // //         _verificationId = verificationId;
// // // //       });
// // // //     };
// // // //
// // // //     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
// // // //       setState(() {
// // // //         _verificationId = verificationId;
// // // //       });
// // // //     };
// // // //
// // // //     await FirebaseAuth.instance.verifyPhoneNumber(
// // // //       phoneNumber: widget.phoneNumber,
// // // //       verificationCompleted: verificationCompleted,
// // // //       verificationFailed: verificationFailed,
// // // //       codeSent: codeSent,
// // // //       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
// // // //       timeout: const Duration(seconds: 60), // Adjust the timeout as needed
// // // //     );
// // // //   }
// // // //
// // // //   Future<void> _submitSmsCode() async {
// // // //     try {
// // // //       final AuthCredential credential = PhoneAuthProvider.credential(
// // // //         verificationId: _verificationId,
// // // //         smsCode: _smsController.text.trim(),
// // // //       );
// // // //
// // // //       final User? user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
// // // //
// // // //       if (user != null) {
// // // //         print("lala12 ${user.uid}");
// // // //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: user.uid)));
// // // //       } else {
// // // //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in")));
// // // //       }
// // // //     } catch (e) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to verify SMS code: $e")));
// // // //     }
// // // //   }
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text('Verify Phone'),
// // // //       ),
// // // //       body: Padding(
// // // //         padding: EdgeInsets.all(16.0),
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: <Widget>[
// // // //             Text("Enter the code sent to ${widget.phoneNumber}"),
// // // //             TextField(
// // // //               controller: _smsController,
// // // //               decoration: InputDecoration(labelText: 'SMS Code'),
// // // //               keyboardType: TextInputType.number,
// // // //             ),
// // // //             SizedBox(height: 20),
// // // //             ElevatedButton(
// // // //               onPressed: _submitSmsCode,
// // // //               child: Text('Verify'),
// // // //             )
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// // // import 'chat_screen.dart';  // Assuming this is your chat screen where you want to redirect
// // //
// // // class PhoneVerificationScreen extends StatefulWidget {
// // //   final String phoneNumber;
// // //   final User user;
// // //
// // //   PhoneVerificationScreen({Key? key, required this.phoneNumber, required this.user}) : super(key: key);
// // //
// // //   @override
// // //   _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
// // // }
// // //
// // // class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
// // //   final _smsController = TextEditingController();
// // //   final _phoneNumberController = TextEditingController();
// // //   String _verificationId = "";
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _verifyPhoneNumber(widget.phoneNumber);
// // //     _phoneNumberController.text = widget.phoneNumber; // Initialize with current phone number
// // //   }
// // //
// // //   Future<void> _verifyPhoneNumber(String phoneNumber) async {
// // //     final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
// // //       await FirebaseAuth.instance.signInWithCredential(credential);
// // //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: widget.user.uid,)));
// // //     };
// // //
// // //     final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text("Verification failed. Error: ${e.message}")),
// // //       );
// // //     };
// // //
// // //     final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
// // //       setState(() {
// // //         _verificationId = verificationId;
// // //       });
// // //     };
// // //
// // //     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
// // //       setState(() {
// // //         _verificationId = verificationId;
// // //       });
// // //     };
// // //
// // //     await FirebaseAuth.instance.verifyPhoneNumber(
// // //       phoneNumber: phoneNumber,
// // //       verificationCompleted: verificationCompleted,
// // //       verificationFailed: verificationFailed,
// // //       codeSent: codeSent,
// // //       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
// // //       timeout: const Duration(seconds: 60),
// // //     );
// // //   }
// // //
// // //   Future<void> _submitSmsCode() async {
// // //     try {
// // //       final AuthCredential credential = PhoneAuthProvider.credential(
// // //         verificationId: _verificationId,
// // //         smsCode: _smsController.text.trim(),
// // //       );
// // //
// // //       final User? user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
// // //
// // //       if (user != null) {
// // //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: user.uid)));
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in")));
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to verify SMS code: $e")));
// // //     }
// // //   }
// // //
// // //   void _resendCode() {
// // //     String phoneNumber = _phoneNumberController.text.trim();
// // //     _verifyPhoneNumber(phoneNumber);
// // //     FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({'phoneNumber': phoneNumber});
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('Verify Phone'),
// // //       ),
// // //       body: Padding(
// // //         padding: EdgeInsets.all(16.0),
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: <Widget>[
// // //             InternationalPhoneNumberInput(
// // //               onInputChanged: (PhoneNumber number) {},
// // //               onInputValidated: (bool value) {},
// // //               selectorConfig: SelectorConfig(
// // //                 selectorType: PhoneInputSelectorType.DIALOG,
// // //               ),
// // //               ignoreBlank: false,
// // //               autoValidateMode: AutovalidateMode.disabled,
// // //               selectorTextStyle: TextStyle(color: Colors.black),
// // //               initialValue: PhoneNumber(phoneNumber: widget.phoneNumber),
// // //               textFieldController: _phoneNumberController,
// // //               formatInput: false,
// // //               keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
// // //               inputBorder: OutlineInputBorder(),
// // //               onSaved: (PhoneNumber number) {},
// // //             ),
// // //             TextField(
// // //               controller: _smsController,
// // //               decoration: InputDecoration(labelText: 'SMS Code'),
// // //               keyboardType: TextInputType.number,
// // //             ),
// // //             SizedBox(height: 20),
// // //             ElevatedButton(
// // //               onPressed: _submitSmsCode,
// // //               child: Text('Verify'),
// // //             ),
// // //             ElevatedButton(
// // //               onPressed: _resendCode,
// // //               child: Text('Resend Code'),
// // //             ),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 _phoneNumberController.clear();
// // //               },
// // //               child: Text('Change Phone Number'),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// // import 'chat_screen.dart'; // Assuming you have a HomeScreen where you want to redirect after verification
// //
// // class PhoneVerificationScreen extends StatefulWidget {
// //   final String phoneNumber;
// //   final User user;
// //
// //   PhoneVerificationScreen({Key? key, required this.phoneNumber, required this.user}) : super(key: key);
// //
// //   @override
// //   _PhoneVerificationScreenState createState() => _PhoneVerificationScreenState();
// // }
// //
// // class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
// //   final _smsController = TextEditingController();
// //   final _phoneNumberController = TextEditingController();
// //   String _verificationId = "";
// //   bool _isEditing = false;
// //   PhoneNumber number = PhoneNumber(isoCode: 'RO');
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _verifyPhoneNumber(widget.phoneNumber);
// //     _phoneNumberController.text = widget.phoneNumber; // Assuming '+40746099067' is passed
// //     _parsePhoneNumber();
// //   }
// //
// //   void _parsePhoneNumber() {
// //     PhoneNumber.getRegionInfoFromPhoneNumber(widget.phoneNumber).then((value) {
// //       setState(() {
// //         number = value;
// //       });
// //     });
// //   }
// //
// //   Future<void> _verifyPhoneNumber(String phoneNumber) async {
// //     final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async {
// //       await FirebaseAuth.instance.signInWithCredential(credential);
// //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: widget.user.uid,)));
// //     };
// //
// //     final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Verification failed. Error: ${e.message}")),
// //       );
// //     };
// //
// //     final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
// //       setState(() {
// //         _verificationId = verificationId;
// //       });
// //     };
// //
// //     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
// //       setState(() {
// //         _verificationId = verificationId;
// //       });
// //     };
// //
// //     await FirebaseAuth.instance.verifyPhoneNumber(
// //       phoneNumber: phoneNumber,
// //       verificationCompleted: verificationCompleted,
// //       verificationFailed: verificationFailed,
// //       codeSent: codeSent,
// //       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
// //       timeout: const Duration(seconds: 60),
// //     );
// //   }
// //
// //   Future<void> _submitSmsCode() async {
// //     try {
// //       final AuthCredential credential = PhoneAuthProvider.credential(
// //         verificationId: _verificationId,
// //         smsCode: _smsController.text.trim(),
// //       );
// //
// //       final User? user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
// //
// //       if (user != null) {
// //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChatScreen(currentUserId: user.uid)));
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in")));
// //       }
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to verify SMS code: $e")));
// //     }
// //   }
// //
// //   void _resendCode() {
// //     String phoneNumber = _phoneNumberController.text.trim();
// //     _verifyPhoneNumber(phoneNumber);
// //     FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(widget.user.uid)
// //         .update({'phoneNumber': phoneNumber});
// //   }
// //
// //   void _toggleEditing() {
// //     setState(() {
// //       _isEditing = !_isEditing;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Verify Phone'),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             _isEditing
// //                 ? InternationalPhoneNumberInput(
// //               onInputChanged: (PhoneNumber number) {
// //                 print(number.phoneNumber); // Updated number
// //               },
// //               initialValue: number,
// //               selectorConfig: SelectorConfig(
// //                 selectorType: PhoneInputSelectorType.DIALOG,
// //               ),
// //               textFieldController: _phoneNumberController,
// //               formatInput: false,
// //               keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
// //               inputBorder: OutlineInputBorder(),
// //             )
// //                 : Text("Phone Number: ${widget.phoneNumber}"),
// //             TextField(
// //               controller: _smsController,
// //               decoration: InputDecoration(labelText: 'SMS Code'),
// //               keyboardType: TextInputType.number,
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: _submitSmsCode,
// //               child: Text('Verify'),
// //             ),
// //             ElevatedButton(
// //               onPressed: _toggleEditing,
// //               child: Text(_isEditing ? 'Save Changes' : 'Edit Phone Number'),
// //             ),
// //             ElevatedButton(
// //               onPressed: _resendCode,
// //               child: Text('Resend Code'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'chat_screen.dart'; // Assuming you have a HomeScreen where you want to redirect after verification
//
// class PhoneVerificationScreen extends StatefulWidget {
//   String phoneNumber;
//   final User user;
//
//   PhoneVerificationScreen(
//       {Key? key, required this.phoneNumber, required this.user})
//       : super(key: key);
//
//   @override
//   _PhoneVerificationScreenState createState() =>
//       _PhoneVerificationScreenState();
// }
//
// class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
//   final _smsController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   String _verificationId = "";
//   bool _isEditing = false;
//   PhoneNumber number = PhoneNumber(isoCode: 'RO');
//
//   @override
//   void initState() {
//     super.initState();
//     _verifyPhoneNumber(widget.phoneNumber);
//     _parsePhoneNumber(widget.phoneNumber);
//   }
//
//   // void _parsePhoneNumber(String phoneNumber) {
//   //   PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber).then((value) {
//   //     setState(() {
//   //       number = value;
//   //       _phoneNumberController.text = value.phoneNumber!;
//   //     });
//   //   });
//   // }
//
//   void _parsePhoneNumber(String phoneNumber) {
//     PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber).then((value) {
//       setState(() {
//         _fullPhoneNumber = value;
//         _phoneNumberController.text = _fullPhoneNumber.phoneNumber!;
//       });
//     });
//   }
//
//   Future<void> _verifyPhoneNumber(String phoneNumber) async {
//     final PhoneVerificationCompleted verificationCompleted =
//         (PhoneAuthCredential credential) async {
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//               builder: (context) => ChatScreen(
//                     currentUserId: widget.user.uid,
//                   )));
//     };
//
//     final PhoneVerificationFailed verificationFailed =
//         (FirebaseAuthException e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Verification failed. Error: ${e.message}")),
//       );
//     };
//
//     final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
//       setState(() {
//         _verificationId = verificationId;
//       });
//     };
//
//     final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
//         (String verificationId) {
//       setState(() {
//         _verificationId = verificationId;
//       });
//     };
//
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: verificationCompleted,
//       verificationFailed: verificationFailed,
//       codeSent: codeSent,
//       codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
//       timeout: const Duration(seconds: 60),
//     );
//   }
//
//   Future<void> _submitSmsCode() async {
//     try {
//       final AuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: _smsController.text.trim(),
//       );
//
//       final User? user =
//           (await FirebaseAuth.instance.signInWithCredential(credential)).user;
//
//       if (user != null) {
//         Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => ChatScreen(currentUserId: user.uid)));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Failed to sign in")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to verify SMS code: $e")));
//     }
//   }
//
//   void _savePhoneNumber() async {
//     String fullNumber =
//         _phoneNumberController.text.trim(); // Full number with country code
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.user.uid)
//         .update({'phoneNumber': fullNumber});
//     _verifyPhoneNumber(fullNumber); // Resend verification to new number
//     _toggleEditing(); // Switch back to non-editing mode
//   }
//
//   void _saveChanges() async {
//     String fullNumber = _phoneNumberController.text.trim();
//     // You can add validation here if needed
//     if (fullNumber.isNotEmpty && fullNumber != widget.phoneNumber) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(widget.user.uid)
//             .update({'phoneNumber': fullNumber});
//
//         // If the phone number was successfully updated in the database
//         setState(() {
//           _isEditing = false; // Turn off editing mode
//           widget.phoneNumber = fullNumber; // Update the local reference if you want to keep the state up-to-date
//         });
//         _verifyPhoneNumber(fullNumber); // Optionally resend verification
//       } catch (e) {
//         // Handle errors, e.g., show an error message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to update phone number: $e")),
//         );
//       }
//     }
//   }
//
//   void _toggleEditing() {
//     setState(() {
//       if (_isEditing) {
//         _saveChanges(); // Attempt to save changes when toggling off
//       } else {
//         _isEditing = true; // Enable editing mode
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Verify Phone'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _isEditing
//                 ? InternationalPhoneNumberInput(
//                     onInputChanged: (PhoneNumber number) {
//                       print(number.phoneNumber); // Updated number
//                     },
//                     initialValue: number,
//                     selectorConfig: SelectorConfig(
//                       selectorType: PhoneInputSelectorType.DIALOG,
//                     ),
//                     textFieldController: _phoneNumberController,
//                     formatInput: false,
//                     keyboardType: TextInputType.numberWithOptions(
//                         signed: true, decimal: true),
//                     inputBorder: OutlineInputBorder(),
//                   )
//                 : Text("Phone Number: ${_phoneNumberController.text}"),
//             TextField(
//               controller: _smsController,
//               decoration: InputDecoration(labelText: 'SMS Code'),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _submitSmsCode,
//               child: Text('Verify'),
//             ),
//             ElevatedButton(
//               onPressed: _toggleEditing,
//               child: Text(_isEditing ? 'Save Changes' : 'Edit Phone Number'),
//             ),
//             if (!_isEditing) // Resend button only visible when not editing
//               ElevatedButton(
//                 onPressed: () =>
//                     _verifyPhoneNumber(_phoneNumberController.text.trim()),
//                 // Resend SMS
//                 child: Text('Resend Code'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'chat_screen.dart'; // Assuming you have a ChatScreen where you want to redirect after verification

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final User user;

  PhoneVerificationScreen(
      {Key? key, required this.phoneNumber, required this.user})
      : super(key: key);

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _smsController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _verificationId = "";
  bool _isEditing = false;
  PhoneNumber number = PhoneNumber(isoCode: 'RO');
  String _currentPhoneNumber =
      ""; // New state variable to manage phone number changes

  @override
  void initState() {
    super.initState();
    _currentPhoneNumber = widget.phoneNumber; // Initialize from widget
    _verifyPhoneNumber(_currentPhoneNumber);
    _parsePhoneNumber(_currentPhoneNumber);
  }

  void _parsePhoneNumber(String phoneNumber) {
    PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber).then((value) {
      setState(() {
        number = value;
        _phoneNumberController.text = number.phoneNumber!;
      });
    });
  }

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    currentUserId: widget.user.uid,
                  )));
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed. Error: ${e.message}")),
      );
    };

    final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
      setState(() {
        _verificationId = verificationId;
      });
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> _submitSmsCode() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text.trim(),
      );

      final User? user =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if (user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(currentUserId: user.uid)));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to sign in")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to verify SMS code: $e")));
    }
  }

  void _savePhoneNumber() async {
    String phoneNumber = _phoneNumberController.text.trim();
    if (phoneNumber.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'phoneNumber': phoneNumber});
      setState(() {
        _currentPhoneNumber = phoneNumber; // Update the state variable
        _isEditing = false; // Turn off editing mode
      });
      _verifyPhoneNumber(phoneNumber); // Optionally resend verification
    }
  }

  void _toggleEditing() {
    if (_isEditing) {
      // Save changes if currently editing
      _savePhoneNumber();
    } else {
      setState(() {
        _isEditing = true; // Start editing
      });
    }
  }

  void _resendCode() {
    String phoneNumber = _phoneNumberController.text.trim();
    _verifyPhoneNumber(phoneNumber);
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({'phoneNumber': phoneNumber});
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
            _isEditing
                ? InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      print(number.phoneNumber); // Updated number
                    },
                    initialValue: number,
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                    ),
                    textFieldController: _phoneNumberController,
                    formatInput: false,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputBorder: OutlineInputBorder(),
                  )
                : Text("Phone Number: $_currentPhoneNumber"),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(labelText: 'SMS Code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSmsCode,
              child: Text('Verify'),
            ),
            ElevatedButton(
              onPressed: _toggleEditing,
              child: Text(_isEditing ? 'Save Changes' : 'Edit Phone Number'),
            ),
            ElevatedButton(
              onPressed: _resendCode,
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }
}
