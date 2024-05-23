import 'package:chat_app/screens/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/messages_screen.dart';

class UserListScreen extends StatefulWidget {
  final String currentUserId;

  UserListScreen({required this.currentUserId});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _users = [];
  List<DocumentSnapshot> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = snapshot.docs.where((doc) => doc.id != widget.currentUserId).toList();
      _filteredUsers = _users;
    });
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
    } else {
      setState(() {
        _filteredUsers = _users.where((user) {
          return (user['userName'] as String).toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Conversation'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                DocumentSnapshot user = _filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user['profilePicUrl']),
                  ),
                  title: Text(user['userName']),
                  subtitle: Text(user['email']),
                  onTap: () {
                    _checkAndCreateChatCollection(_filteredUsers[index].id);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MessageScreen(
                          currentUserId: widget.currentUserId,
                          chatId: _filteredUsers[index].id, // DE adaugat realul chatId in loc de asta mocked
                          otherUserId: _filteredUsers[index].id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAndCreateChatCollection(String otherUserId) async {
    DocumentReference chatDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .collection('chats')
        .doc(otherUserId);

    DocumentSnapshot chatDoc = await chatDocRef.get();
    print("lala9 ${chatDoc.exists}");
    if (!chatDoc.exists) {
      await chatDocRef.set({
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'otherUserAvatar': '', // You can set the current user's avatar here
        'otherUserId': otherUserId,
        'otherUserName': '', // You can set the current user's name here
      });
    }

    // Create a corresponding chat document in the other user's chats collection
    DocumentReference otherUserChatDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .collection('chats')
        .doc(widget.currentUserId);

    await otherUserChatDocRef.set({
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'otherUserAvatar': '', // You can set the current user's avatar here
      'otherUserId': widget.currentUserId,
      'otherUserName': '', // You can set the current user's name here
    });
  }
}
