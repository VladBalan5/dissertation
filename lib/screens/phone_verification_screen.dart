import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  bool _isLoading = false;

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
    setState(() {
      _isLoading = true; // Start loading
    });

    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      try {
        await widget.user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        print(e);
        if (e.code == 'provider-already-linked') {
          await widget.user.reauthenticateWithCredential(credential);
        } else {
          throw e;
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading after verification is completed
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            currentUserId: widget.user.uid,
          ),
        ),
      );
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading on failure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Verification failed. Error: ${e.message}",
          ),
        ),
      );
    };

    final PhoneCodeSent codeSent = (String verificationId, int? resendToken) {
      if (!mounted) return;
      setState(() {
        _isLoading = false; // Stop loading when code is sent
        _verificationId = verificationId;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Verification code sent to ${_currentPhoneNumber}",
          ),
        ),
      );
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      if (!mounted) return;
      setState(() {
        _isLoading =
            false; // Ensure loading is stopped if auto retrieval timeout occurs
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
      try {
        await widget.user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          await widget.user.reauthenticateWithCredential(credential);
        } else {
          throw e;
        }
      }

      if (widget.user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(currentUserId: widget.user.uid)));
      } else {
        print("lala6");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to sign in! Try again.",
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to sign in! Try again.",
          ),
        ),
      );
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
                      signed: true,
                      decimal: true,
                    ),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _resendCode,
                  // Disable button while loading
                  child: Text('Resend Code'),
                ),
                SizedBox(width: 10),
                _isLoading
                    ? SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor,
                        size: 20.0,
                      )
                    : Container()
                // Show spinner or an empty container if not loading
              ],
            ),
            // ElevatedButton(
            //   onPressed: _resendCode,
            //   child: Text('Resend Code'),
            // ),
          ],
        ),
      ),
    );
  }
}
