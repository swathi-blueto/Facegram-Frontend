import 'package:flutter/material.dart';
import 'package:project/models/message_model.dart';
import 'package:project/services/chat_service.dart';
import 'package:project/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Added for toast

class MessageScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  final String receiverProfilePic;
  final List<Message> initialMessages;

  const MessageScreen({
    Key? key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverProfilePic,
    required this.initialMessages,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Message> _messages;
  String? _currentUser;
  bool _isSending = false;
  bool _isLoading = false;
  RealtimeChannel? _messageSubscription;
  final FToast _toast = FToast();

  @override
  void initState() {
    super.initState();
    _toast.init(context); 
    _messages = List.from(widget.initialMessages);
    _initializeData();
  }

  void _showToast(String message, {bool isError = false}) {
    _toast.removeQueuedCustomToasts();
    _toast.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: isError ? Colors.red : Colors.green,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _getCurrentUserId();
    if (_messages.isEmpty) {
      await _loadMessages();
    }
    _subscribeToMessages();
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentUserId() async {
    _currentUser = await AuthService.getCurrentUserId();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ChatService.fetchMessages(widget.chatId);
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        _showToast('Failed to load messages: ${e.toString()}', isError: true);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null || _isSending) return;

    setState(() => _isSending = true);
    final messageContent = _messageController.text.trim();
    _messageController.clear();

    try {
      await ChatService.sendMessage(
        widget.chatId,
        _currentUser!,
        messageContent,
      );
      setState(() => _isSending = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        _showToast('Failed to send message: ${e.toString()}', isError: true);
        _messageController.text = messageContent;
      }
    }
  }

  void _subscribeToMessages() {
    _messageSubscription?.unsubscribe();
    
    _messageSubscription = ChatService.subscribeToMessages(
      widget.chatId,
      (newMessage) {
        if (!_messages.any((m) => m.id == newMessage.id)) {
          if (mounted) {
            setState(() {
              _messages.add(newMessage);
            });
            _scrollToBottom();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                widget.receiverProfilePic.isNotEmpty
                    ? widget.receiverProfilePic
                    : 'https://via.placeholder.com/150',
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == _currentUser;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isMe ? Colors.white70 : Colors.black54,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: _isSending ? const CircularProgressIndicator() : const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}