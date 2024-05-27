import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/messages_screen.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/utils/rsa_helper.dart';
import 'package:encrypt/encrypt.dart' as aesEncrypt;

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  ChatScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Stream<List<Chat>> chatStream;
  UserModel? currentUserData;
  String currentUserPrivateKeyRSA = '';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  late aesEncrypt.Encrypter aesEncrypter;
  late aesEncrypt.IV aesIv;

  @override
  void initState() {
    super.initState();
    _initializeChatStream();
    _getCurrentUserInfo();
  }

  void _initializeChatStream () {
    chatStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Chat.fromFirestore(doc.data()))
        .toList());
  }

  Future<void> _getCurrentUserInfo() async {
    String? privateKeyRSA = await secureStorage.read(key:'user-${widget.currentUserId}-privateKeyRSA');
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          currentUserPrivateKeyRSA = privateKeyRSA ?? '';
          currentUserData =
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>, widget.currentUserId);
        });
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
  }

  void _initializeEncryptionAes() {
    final key = aesEncrypt.Key.fromBase64(currentUserData!.aesKey);
    aesIv = aesEncrypt.IV.fromBase64(currentUserData!.aesIV);
    aesEncrypter = aesEncrypt.Encrypter(aesEncrypt.AES(key));
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
      appBar: AppBar(title: Text("Your Chats")),
      body: StreamBuilder<List<Chat>>(
        stream: chatStream,
        builder: (context, snapshot) {
          print("lala3 ${widget.currentUserId}");
          print("lala4 ${snapshot.data}");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            print(snapshot.error); // Log any errors that might occur
            return Center(child: Text('An error occurred!'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No chats found"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final chat = snapshot.data![index];
              return FutureBuilder<String>(
                future: _decryptMessageFromRSA(chat.lastMessage),
                builder: (context, decryptedSnapshot) {
                  if (decryptedSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Decrypting...'),
                    );
                  } else if (decryptedSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error decrypting message'),
                    );
                  } else {
                    _initializeEncryptionAes();
                    String decryptedTextFromAES = aesEncrypter.decrypt64(decryptedSnapshot.data ?? '', iv: aesIv);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat.otherUserAvatar),
                      ),
                      title: Text(chat.otherUserName),
                      subtitle: Text(decryptedTextFromAES),
                      trailing: Text(
                          DateFormat('dd MMM, hh:mm a').format(chat.lastMessageTime)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MessageScreen(
                              currentUserData: currentUserData!,
                              otherUserId: chat.otherUserId,
                              otherUserName: chat.otherUserName,
                              otherUserProfilePicUrl: chat.otherUserAvatar,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserListScreen(
                currentUserData: currentUserData!,
              ),
            ),
          );
        },
        child: Icon(Icons.chat),
        tooltip: 'Start Conversation',
      ),
    );
  }
}
