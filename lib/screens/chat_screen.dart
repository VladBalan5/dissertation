import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../models/message.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded) {
                  return ListView.builder(
                    itemCount: state.messages.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      return ListTile(
                        title: Text(message.text),
                        subtitle: Text(message.senderId),
                      );
                    },
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Send a message...",
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final message = Message(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      senderId: 'currentUserId', // Replace with actual user ID
                      text: _messageController.text,
                      timestamp: Timestamp.now(),
                    );
                    BlocProvider.of<ChatBloc>(context).add(SendMessage(chatId, message));
                    _messageController.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
