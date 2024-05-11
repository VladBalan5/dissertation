import 'package:chat_app/models/chat.dart';
import 'package:chat_app/screens/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  ChatScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Stream<List<Chat>> chatStream;

  @override
  void initState() {
    super.initState();
    chatStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Chat.fromFirestore(doc.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Chats")),
      body: StreamBuilder<List<Chat>>(
        stream: chatStream,
        builder: (context, snapshot) {
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
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(chat.otherUserAvatar),
                ),
                title: Text(chat.otherUserName),
                subtitle: Text(chat.lastMessage),
                trailing: Text(DateFormat('dd MMM, hh:mm a').format(chat.lastMessageTime)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MessageScreen(
                        currentUserId: widget.currentUserId,
                        chatId: "Afdjc6YxCp3iX1VogFFd",
                        // messageId: "V91mHaXN12bbmYtIEP5o",
                        // currentUserId: widget.currentUserId,  // Assuming this is available in the widget
                        // chatId: chat.chatId, // Make sure 'chatId' is being fetched or constructed correctly
                        // otherUserId: chat.otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
