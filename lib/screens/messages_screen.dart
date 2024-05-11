// import 'package:chat_app/models/message.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class MessageScreen extends StatefulWidget {
//   final String chatId;
//   final String messageId;
//
//   MessageScreen({Key? key, required this.chatId, required this.messageId}) : super(key: key);
//
//   @override
//   _MessageScreenState createState() => _MessageScreenState();
// }
//
// class _MessageScreenState extends State<MessageScreen> {
//   final TextEditingController _messageController = TextEditingController();
//
//   Stream<List<Message>> getMessages() {
//     return FirebaseFirestore.instance
//         .collection('chats')
//         .doc(widget.chatId)
//         .collection('messages')
//         .doc(widget.messageId)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Message.fromFirestore(doc.data() as Map<String, dynamic>))
//         .toList());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Messages")),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: StreamBuilder<List<Message>>(
//               stream: getMessages(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (!snapshot.hasData) {
//                   return Center(child: Text("No messages"));
//                 }
//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (ctx, index) {
//                     var message = snapshot.data![index];
//                     bool isMine = message.senderId == widget.messageId;
//                     return ListTile(
//                       title: Align(
//                         alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                           decoration: BoxDecoration(
//                             color: isMine ? Colors.blue : Colors.grey[300],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(message.text),
//                         ),
//                       ),
//                       subtitle: Text(message.senderName),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(labelText: "Send a message..."),
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.send),
//                   onPressed: () {
//                     if (_messageController.text.isNotEmpty) {
//                       FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
//                         'text': _messageController.text,
//                         'senderId': widget.userId,
//                         'senderName': "Your Name", // This should be dynamically obtained or set
//                         'timestamp': FieldValue.serverTimestamp(),
//                       });
//                       _messageController.clear();
//                     }
//                   },
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:chat_app/models/message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageScreen extends StatefulWidget {
  final String chatId;
  final String currentUserId;

  MessageScreen({Key? key, required this.chatId, required this.currentUserId}) : super(key: key);

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
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                print("lala1 ${snapshot.hasData}");
                if (snapshot.hasError) {
                  print(snapshot.error);  // Log any errors
                  return Text("Error: ${snapshot.error}");
                }
                if (!snapshot.hasData) {
                  print("No data available");  // Log no data condition
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
                    print("lala3 ${snapshot.data!.docs[index].data()}");
                    Message message = Message.fromFirestore(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                    print("lala2 ${message.text}");
                    bool isMine = message.senderId == "1"; // Replace with actual user ID
                    return ListTile(
                      title: Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            padding: const EdgeInsets.all(8.0),
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

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('users').doc(widget.currentUserId).collection('chats').doc(widget.chatId).collection('messages').add({
        'senderId': "YourUserId", // Replace with actual user ID
        'senderName': "YourUserName", // Replace with actual user name
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }
}
