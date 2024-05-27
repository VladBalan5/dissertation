import 'dart:developer';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/utils/rsa_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as aesEncrypt;

class MessageScreen extends StatefulWidget {
  final UserModel currentUserData;
  final String otherUserId;
  final String otherUserName;
  final String otherUserProfilePicUrl;

  MessageScreen({
    Key? key,
    required this.currentUserData,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserProfilePicUrl,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String currentUserPrivateKeyRSA = '';
  String currentUserPublicKeyRSA = '';
  late aesEncrypt.Encrypter aesEncrypter;
  late aesEncrypt.IV aesIv;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserKeysRSA();
    _initializeEncryptionAes();
  }

  void _initializeEncryptionAes() {
    final key = aesEncrypt.Key.fromBase64(widget.currentUserData.aesKey);
    aesIv = aesEncrypt.IV.fromBase64(widget.currentUserData.aesIV);
    aesEncrypter = aesEncrypt.Encrypter(aesEncrypt.AES(key));
  }

  Future<void> _loadCurrentUserKeysRSA() async {
    String? privateKeyRSA = await secureStorage.read(key:'user-${widget.currentUserData.userId}-privateKeyRSA');
    setState(() {
      currentUserPrivateKeyRSA = privateKeyRSA ?? '';
      currentUserPublicKeyRSA = widget.currentUserData.publicKeyRSA;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      String aesEncryptedText = aesEncrypter.encrypt(messageText, iv: aesIv).base64;

      // Get other user's public key
      DocumentSnapshot otherUserSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .get();
      String otherUserPublicKeyRSA = otherUserSnapshot['publicKeyRSA'];

      // Encrypt the message with both public keys
      String encryptedMessageForOtherUser = await RsaKeyHelper.encryptWithPublicKey(aesEncryptedText, otherUserPublicKeyRSA);
      String encryptedMessageForCurrentUser = await RsaKeyHelper.encryptWithPublicKey(aesEncryptedText, currentUserPublicKeyRSA);

      // Store encrypted message for both users
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserData.userId)
          .collection('chats')
          .doc(widget.otherUserId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserData.userId,
        'senderName': widget.currentUserData.userName,
        'text': encryptedMessageForCurrentUser,
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserData.userId)
          .collection('chats')
          .doc(widget.otherUserId)
          .set({
        'lastMessage': encryptedMessageForCurrentUser,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserAvatar': widget.otherUserProfilePicUrl,
        'otherUserId': widget.otherUserId,
        'otherUserName': widget.otherUserName,
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .collection('chats')
          .doc(widget.currentUserData.userId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserData.userId,
        'senderName': widget.currentUserData.userName,
        'text': encryptedMessageForOtherUser,
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .collection('chats')
          .doc(widget.currentUserData.userId)
          .set({
        'lastMessage': encryptedMessageForOtherUser,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserAvatar': widget.currentUserData.profilePicUrl,
        'otherUserId': widget.currentUserData.userId,
        'otherUserName': widget.currentUserData.userName,
      });

      _messageController.clear();
    }
  }

  Future<String> _decryptMessageFromRSA(String encryptedMessage) async {
    try {
      if (currentUserPrivateKeyRSA.isNotEmpty) {
        print('Attempting to decrypt message: $encryptedMessage');
        return await RsaKeyHelper.decryptWithPrivateKey(encryptedMessage, currentUserPrivateKeyRSA);
      } else {
        throw Exception('Current user private key is empty.');
      }
    } catch (e) {
      print('Decryption error: $e');
      return 'Error decrypting message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.otherUserProfilePicUrl),
            ),
            SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserData.userId)
                  .collection('chats')
                  .doc(widget.otherUserId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData) {
                  return Center(child: Text("No messages yet"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    Timestamp? timestamp = data['timestamp'] as Timestamp?;
                    if (timestamp == null) {
                      return Container();
                    }
                    Message message = Message.fromFirestore(data);
                    bool isMine = message.senderId == widget.currentUserData.userId;
                    return FutureBuilder<String>(
                      future: _decryptMessageFromRSA(message.text),
                      builder: (context, decryptedSnapshot) {
                        if (decryptedSnapshot.connectionState == ConnectionState.waiting) {
                          return ListTile(
                            title: Align(
                              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isMine ? Colors.blue[200] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Decrypting...'),
                              ),
                            ),
                          );
                        } else if (decryptedSnapshot.hasError) {
                          return ListTile(
                            title: Align(
                              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isMine ? Colors.red[200] : Colors.red[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Error decrypting message'),
                              ),
                            ),
                          );
                        } else {
                          String decryptedTextFromAES = aesEncrypter.decrypt64(decryptedSnapshot.data ?? '', iv: aesIv);
                          return ListTile(
                            title: Align(
                              alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isMine ? Colors.blue[200] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(decryptedTextFromAES),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: "Type your message here..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
