import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromFirestore(Map<String, dynamic> firestore) {
    return Message(
      senderId: firestore['senderId'] as String,
      senderName: firestore['senderName'] as String,
      text: firestore['text'] as String,
      timestamp: (firestore['timestamp'] as Timestamp).toDate(),
    );
  }

}
