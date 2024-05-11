import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatefulWidget {
  final String currentUserId;
  final String chatId;
  final String otherUserId;

  MessageScreen({Key? key, required this.currentUserId, required this.chatId, required this.otherUserId}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    // Example logic to fetch messages for a specific chat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          var message = messages[index];
          return ListTile(
            title: Text(message['text']), // Just an example
            subtitle: Text(message['timestamp'].toString()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add send message functionality
        },
        child: Icon(Icons.send),
      ),
    );
  }
}
