// import 'package:project/models/user_profile.dart';
// import 'package:flutter/material.dart';
// import 'package:project/models/message_model.dart';
// import 'package:project/services/friend_service.dart';
// import 'package:project/services/auth_service.dart';
// import 'package:project/screens/message_screen.dart';
// import 'package:project/services/chat_service.dart';

// class ContactsScreen extends StatefulWidget {
//   const ContactsScreen({super.key});

//   @override
//   _ContactsScreenState createState() => _ContactsScreenState();
// }

// class _ContactsScreenState extends State<ContactsScreen> {
//   List<PotentialFriend> _potentialFriends = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   String? _currentUser;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       _currentUser = await AuthService.getCurrentUserId();
//       await _loadPotentialFriends(); // Load potential friends
//     } catch (e) {
//       _handleError(e);
//     }
//   }

//   Future<void> _loadPotentialFriends() async {
//     if (_currentUser == null) return;

//     setState(() => _isLoading = true);

//     try {
//       final friends = await FriendService.getFriends(_currentUser!);
//       setState(() {
//         _potentialFriends = friends
//             .where((friend) => friend.id != _currentUser)
//             .toList();
//         _isLoading = false;
//         _errorMessage = null;
//       });
//     } catch (e) {
//       _handleError(e);
//     }
//   }

//   Future<void> _startChat(PotentialFriend friend) async {
//     if (_currentUser == null) return;

//     try {
//       final chatId = await ChatService.createChatIfNotExists(
//         _currentUser!,
//         friend.id,
//       );

//       final messages = await ChatService.fetchMessages(chatId);

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MessageScreen(
//             chatId: chatId,
//             receiverId: friend.id,
//             receiverName: friend.firstName,
//             receiverProfilePic: friend.profilePic ?? 'default_profile_pic_url',
//             initialMessages: messages,
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
//       );
//     }
//   }

//   void _handleError(dynamic error) {
//     setState(() {
//       _errorMessage = error.toString();
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Messages')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//           ? Center(child: Text(_errorMessage!))
//           : _potentialFriends.isEmpty
//           ? const Center(child: Text('No potential friends to chat with'))
//           : ListView.builder(
//               itemCount: _potentialFriends.length,
//               itemBuilder: (context, index) {
//                 final friend = _potentialFriends[index];
//                 return ListTile(
//                   leading: CircleAvatar(
//                     backgroundImage: NetworkImage(
//                       friend.profilePic ?? 'default_profile_pic_url',
//                     ),
//                   ),
//                   title: Text(friend.firstName),
//                   onTap: () => _startChat(friend), // Change to PotentialFriend
//                 );
//               },
//             ),
//     );
//   }
// }



import 'package:project/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:project/models/message_model.dart';
import 'package:project/services/friend_service.dart';
import 'package:project/services/auth_service.dart';
import 'package:project/screens/message_screen.dart';
import 'package:project/services/chat_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<PotentialFriend> _potentialFriends = [];
  Map<String, Message?> _latestMessages = {};
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _currentUser = await AuthService.getCurrentUserId();
      await _loadPotentialFriends();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _loadPotentialFriends() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final friends = await FriendService.getFriends(_currentUser!);
      final filteredFriends = friends.where((friend) => friend.id != _currentUser).toList();
      
      final messagesMap = <String, Message?>{};
      for (final friend in filteredFriends) {
        try {
          final chatId = await ChatService.createChatIfNotExists(_currentUser!, friend.id);
          final messages = await ChatService.fetchMessages(chatId);
          messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          messagesMap[friend.id] = messages.isNotEmpty ? messages.first : null;
        } catch (e) {
          print('Error loading messages for ${friend.id}: $e');
          messagesMap[friend.id] = null;
        }
      }

      setState(() {
        _potentialFriends = filteredFriends;
        _latestMessages = messagesMap;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _startChat(PotentialFriend friend) async {
    if (_currentUser == null) return;

    try {
      final chatId = await ChatService.createChatIfNotExists(
        _currentUser!,
        friend.id,
      );

      final messages = await ChatService.fetchMessages(chatId);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessageScreen(
            chatId: chatId,
            receiverId: friend.id,
            receiverName: friend.firstName,
            receiverProfilePic: friend.profilePic?.isNotEmpty == true 
              ? friend.profilePic!
              : 'https://cdn.pixabay.com/photo/2023/02/18/11/00/icon-7797704_640.png',
            initialMessages: messages,
          ),
        ),
      ).then((_) => _loadPotentialFriends());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
      );
    }
  }

  void _handleError(dynamic error) {
    setState(() {
      _errorMessage = error.toString();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _potentialFriends.isEmpty
                  ? const Center(child: Text('No contacts to chat with'))
                  : ListView.builder(
                      itemCount: _potentialFriends.length,
                      itemBuilder: (context, index) {
                        final friend = _potentialFriends[index];
                        final latestMessage = _latestMessages[friend.id];
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            child: friend.profilePic?.isNotEmpty == true
                                ? ClipOval(
                                    child: Image.network(
                                      friend.profilePic!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.person, color: Colors.white);
                                      },
                                    ),
                                  )
                                : const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(friend.firstName),
                          subtitle: latestMessage != null
                              ? Text(
                                  latestMessage.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                )
                              : const Text(
                                  'Start a conversation',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                          trailing: latestMessage != null
                              ? Text(
                                  _formatTime(latestMessage.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                          onTap: () => _startChat(friend),
                        );
                      },
                    ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}