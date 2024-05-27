import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/messages_screen.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chat_app/utils/rsa_helper.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;

  ChatScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Stream<List<Chat>> chatStream;
  UserModel? currentUserData;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    chatStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Chat.fromFirestore(doc.data()))
        .toList());
    getCurrentUserInfo(widget.currentUserId);
  }

  Future<void> getCurrentUserInfo(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserData =
              UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userId);
        });
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
  }

  Future<String> _decryptMessage(String encryptedMessage) async {
    try {
      String? privateKey = await secureStorage.read(key: 'user-${widget.currentUserId}-privateKey');
      if (privateKey != null) {
        return await RsaKeyHelper.decryptWithPrivateKey(encryptedMessage, privateKey);
      } else {
        throw Exception('Private key not found');
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
                future: _decryptMessage(chat.lastMessage),
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
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(chat.otherUserAvatar),
                      ),
                      title: Text(chat.otherUserName),
                      subtitle: Text(decryptedSnapshot.data ?? 'Error decrypting message'),
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
