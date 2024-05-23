import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final UserModel currentUserData;
  final Chat otherUserData;

  MessageScreen({Key? key, this.chatId = "", required this.currentUserId, required this.otherUserId, required this.currentUserData, required this.otherUserData})
      : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserId)
                  .collection('chats')
                  .doc(widget.otherUserId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error); // Log any errors
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData) {
                  print("No data available"); // Log no data condition
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
                    Message message = Message.fromFirestore(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);
                    bool isMine =
                        message.senderId == widget.currentUserId;
                    return ListTile(
                      title: Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isMine ? Colors.blue[200] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message.text),
                        ),
                      ),
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
                    decoration:
                        InputDecoration(labelText: "Type your message here..."),
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

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('chats')
          .doc(widget.otherUserId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId,
        'senderName': "YourUserName",
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('chats')
          .doc(widget.otherUserId)
          .set({
        'lastMessage': _messageController.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserAvatar': '', // You can set the current user's avatar here
        'otherUserId': widget.otherUserId,
        'otherUserName': '', // You can set the current user's name here
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .collection('chats')
          .doc(widget.currentUserId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId, // Replace with actual user ID
        'senderName': "YourUserName", // Replace with actual user name
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.otherUserId)
          .collection('chats')
          .doc(widget.currentUserId)
          .set({
        'lastMessage': _messageController.text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserAvatar': '', // You can set the current user's avatar here
        'otherUserId': widget.currentUserId,
        'otherUserName': '', // You can set the current user's name here
      });

      _messageController.clear();
    }
  }
}
