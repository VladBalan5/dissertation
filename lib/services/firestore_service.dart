import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromFirestore(doc.data()))
        .toList());
  }

  // Future<void> sendMessage(String chatId, Message message) {
  //   return _db.collection('chats').doc(chatId).collection('messages').add(message.toMap());
  // }
  Future<void> sendMessage(String chatId, Message message) async {
    // return _db.collection('chats').doc(chatId).collection('messages').add(message.toMap());
  }
}
