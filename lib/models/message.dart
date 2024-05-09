import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  Message({required this.id, required this.senderId, required this.text, required this.timestamp});

  factory Message.fromFirestore(Map<String, dynamic> firestore) {
    return Message(
      id: firestore['id'],
      senderId: firestore['senderId'],
      text: firestore['text'],
      timestamp: firestore['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
