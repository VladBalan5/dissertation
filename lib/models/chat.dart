import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;

  Chat({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory Chat.fromFirestore(Map<String, dynamic> firestore) {
    return Chat(
      otherUserId: firestore['otherUserId'] as String,
      otherUserName: firestore['otherUserName'] as String,
      otherUserAvatar: firestore['otherUserAvatar'] as String,
      lastMessage: firestore['lastMessage'] as String,
      lastMessageTime: (firestore['lastMessageTime'] as Timestamp).toDate(),
    );
  }

}
