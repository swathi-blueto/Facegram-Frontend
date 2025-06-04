import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/models/user_profile.dart';
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
  final _toast = FToast();

  @override
  void initState() {
    super.initState();
    _toast.init(context);
    _initializeData();
  }

  void _showToast(String message, {bool isError = false}) {
  _toast.removeQueuedCustomToasts();
  _toast.showToast(
    child: Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isError ? Colors.red : Colors.blueAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // This ensures the row takes minimum space
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Flexible( // This allows the text to wrap if needed
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 2),
  );
}

 Future<void> _initializeData() async {
  try {
    _currentUser = await AuthService.getCurrentUserId();
    if (mounted) {
      await _loadPotentialFriends();
    }
  } catch (e) {
    _handleError(e);
  }
}

Future<void> _loadPotentialFriends() async {
  if (_currentUser == null || !mounted) return;

  try {
    if (mounted) {
      setState(() => _isLoading = true);
    }

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
        debugPrint('Error loading messages for ${friend.id}: $e');
        messagesMap[friend.id] = null;
      }
    }

    if (mounted) {
      setState(() {
        _potentialFriends = filteredFriends;
        _latestMessages = messagesMap;
        _isLoading = false;
        _errorMessage = null;
      });
    }
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
      _showToast('Failed to start chat: ${e.toString()}', isError: true);
    }
  }

void _handleError(dynamic error) {
  _showToast(error.toString(), isError: true);
  if (mounted) {
    setState(() {
      _errorMessage = error.toString();
      _isLoading = false;
    });
  }
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