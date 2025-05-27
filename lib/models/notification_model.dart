import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final String title;
  final String body;
  final String type;
  final String? relatedId;
  final String? commentId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.commentId,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    
    final fromUser = json['from_user_id'] is Map ? json['from_user_id'] : {};
    
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fromUserId: fromUser['id']?.toString() ?? '',
      fromUserName: fromUser['first_name']?.toString(),
      fromUserAvatar: fromUser['profile_pic']?.toString(),
      title: _getTitleFromType(json['type']),
      body: json['body'] ?? json['message'] ?? '', // Use both possible fields
      type: json['type']?.toString() ?? 'general',
      relatedId: json['related_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      isRead: json['is_read'] ?? false,
    );
  }

  static String _getTitleFromType(String? type) {
    switch (type) {
      case 'like': return 'New Like';
      case 'comment': return 'New Comment';
      case 'message': return 'New Message';
      case 'friend_request': return 'Friend Request';
      default: return 'New Notification';
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }

  IconData get icon {
    switch (type) {
      case 'like': return Icons.thumb_up;
      case 'comment': return Icons.comment;
      case 'friend_request': return Icons.person_add;
      case 'friend_accept': return Icons.person_add_alt_1;
      case 'message': return Icons.message;
      default: return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'like': return Colors.blue;
      case 'comment': return Colors.green;
      case 'friend_request': return Colors.purple;
      case 'friend_accept': return Colors.teal;
      case 'message': return Colors.orange;
      default: return Colors.grey;
    }
  }
}