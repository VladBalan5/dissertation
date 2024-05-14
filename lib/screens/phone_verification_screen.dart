import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'chat_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  String phoneNumber;
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
  PhoneNumber phoneNumberwithProps = PhoneNumber(isoCode: 'RO');
  String _currentPhoneNumber = "";

  @override
  void initState() {
    super.initState();
    initializeCurrentPhoneNumber();
    _initializePhoneController();
    _verifyPhoneNumber();
  }

  void initializeCurrentPhoneNumber() {
    setState(() {
      _currentPhoneNumber = widget.phoneNumber;
    });
  }

  void _initializePhoneController() {
    PhoneNumber.getRegionInfoFromPhoneNumber(_currentPhoneNumber).then((value) {
      setState(() {
        phoneNumberwithProps = value;
        _phoneNumberController.text = phoneNumberwithProps.phoneNumber!;
      });
    });
  }

  Future<void> _verifyPhoneNumber() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification code sent to ${_currentPhoneNumber}")),
      );
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      setState(() {
        _verificationId = verificationId;
      });
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _currentPhoneNumber,
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
    String phoneNumber = _currentPhoneNumber;
    if (phoneNumber.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({'phoneNumber': phoneNumber});
      setState(() {
        _isEditing = false; // Turn off editing mode
      });
      _verifyPhoneNumber(); // Optionally resend verification
    }
  }

  void _toggleEditing() {
    if (_isEditing) {
      _savePhoneNumber();
    } else {
      setState(() {
        _isEditing = true; // Start editing
      });
    }
  }

  void _resendCode() {
    _verifyPhoneNumber();
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({'phoneNumber': _currentPhoneNumber});
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
                      _currentPhoneNumber = number.phoneNumber!;
                      phoneNumberwithProps = number;
                      print(number.phoneNumber); // Updated number
                    },
                    initialValue: phoneNumberwithProps,
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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleEditing,
              child: Text(_isEditing ? 'Save Changes' : 'Edit Phone Number'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(labelText: 'SMS Code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSmsCode,
              child: Text('Verify Code'),
            ),
            SizedBox(height: 10),
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
