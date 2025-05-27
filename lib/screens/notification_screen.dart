import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/services/notification_service.dart';
import 'package:project/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;
  late StreamSubscription _notificationStream;
  RealtimeChannel? _notificationChannel;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
   
  _notificationChannel?.unsubscribe().then((_) {
   
  }).catchError((error) {
    print(' Error unsubscribing from channel: $error');
  });
 
    _notificationStream.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = await AuthService.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      final response = await NotificationService.fetchNotifications(userId);
      
      setState(() {
        _notifications = response
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
void _setupRealtimeListener() async {
 
  final userId = await AuthService.getCurrentUserId();
  if (userId == null) {
  
    return;
  }

 
  _notificationChannel = NotificationService.getRealtimeNotifications(
    userId,
    (notification) {
      
      if (mounted) {
        
        setState(() {
          _notifications.insert(0, notification);
        });
      } else {
        print(' Widget not mounted, cannot update UI');
      }
    },
  );
}


  Future<void> _handleDismiss(String id) async {
    try {
      await NotificationService.deleteNotification(id);
      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           
            Navigator.pushReplacementNamed(context, "/home"); 
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildErrorWidget();
    if (_notifications.isEmpty) return _buildEmptyWidget();
    
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _handleDismiss(notification.id),
            child: _buildNotificationTile(notification),
          );
        },
      ),
    );
  }

Widget _buildNotificationTile(NotificationModel notification) {
  return ListTile(
    leading: _buildNotificationLeading(notification),
    title: Text(notification.title),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (notification.fromUserName != null)
          Text(notification.fromUserName!,
              style: TextStyle(fontWeight: FontWeight.bold)),
        Text(notification.body),
        Text(notification.timeAgo,
            style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
    trailing: !notification.isRead 
        ? const Icon(Icons.circle, color: Colors.blue, size: 12)
        : null,
    onTap: () => _handleNotificationTap(notification),
  );
}

Widget _buildNotificationLeading(NotificationModel notification) {
  if (notification.fromUserAvatar != null) {
    return CircleAvatar(
      backgroundImage: NetworkImage(notification.fromUserAvatar!),
      child: notification.fromUserAvatar == null 
          ? Icon(notification.icon, color: notification.iconColor)
          : null,
    );
  }
  return CircleAvatar(
    child: Icon(notification.icon, color: notification.iconColor),
  );
}

  Widget _buildNotificationIcon(NotificationModel notification) {
    switch (notification.type) {
      case 'message':
        return const CircleAvatar(child: Icon(Icons.message));
      case 'friend_request':
        return const CircleAvatar(child: Icon(Icons.person_add));
      default:
        return const CircleAvatar(child: Icon(Icons.notifications));
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'message':
        // Navigator.push(context, MessageScreen(chatId: notification.relatedId));
        break;
      case 'friend_request':
        // Show friend request dialog
        break;
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text('Failed to load notifications', 
              style: Theme.of(context).textTheme.titleMedium),
          Text(_error!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Your notifications will appear here',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}


