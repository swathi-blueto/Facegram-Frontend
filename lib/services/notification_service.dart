import 'package:flutter/foundation.dart';
import 'package:project/constants/api_constants.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        
      },
    );
  }

  Stream<List<Map<String, dynamic>>> setupGlobalRealtimeListener(
    String userId,
  ) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          if (data.isNotEmpty && data.first['is_read'] == false) {
            final fromUserId = data.first['from_user_id'];

            Map<String, dynamic> fromUser = {};

            final userResponse = await _supabase
                .from('users')
                .select('first_name, profile_pic')
                .eq('id', fromUserId)
                .maybeSingle();

            if (userResponse != null) {
              fromUser = userResponse;
            }

            await _showLocalNotification(
              title:
                  '${fromUser['first_name'] ?? 'Someone'} sent you a ${_getNotificationTitle(data.first['type'])}',
              body: data.first['message'] ?? '',
              payload: jsonEncode(data.first),
              imageUrl: fromUser['profile_pic'],
            );
          }
          return data;
        });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
    String? imageUrl,
  }) async {
   

    BigPictureStyleInformation? bigPictureStyle;
    AndroidBitmap<Object>? largeIcon;

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          bigPictureStyle = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(bytes),
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: body,
          );

          largeIcon = ByteArrayAndroidBitmap(bytes);
        }
      }
    } catch (e) {
      print('Error loading notification image: $e');
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channel_id',
          'Notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          largeIcon:
              largeIcon ??
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: bigPictureStyle,
        );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'message':
        return 'New Message';
      case 'friend_request':
        return 'Friend Request';
      case 'like':
        return 'New Like';
      case 'comment':
        return 'New Comment';
      default:
        return 'New Notification';
    }
  }

  static Future<List<dynamic>> fetchNotifications(String userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    } catch (e) {
      print(e);
      throw Exception('Error fetching notifications: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  static RealtimeChannel getRealtimeNotifications(
    String userId,
    Function(NotificationModel) onNotificationReceived,
  ) {
    final channel = Supabase.instance.client.channel('notifications_$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null) {
              try {
                final notification = NotificationModel.fromJson(
                  Map<String, dynamic>.from(data),
                );

                onNotificationReceived(notification);
              } catch (e) {
                print(' Error parsing notification: $e');
              }
            } else {
              print('Notification data is null');
            }
          },
        )
        .subscribe((error, [_]) {
          if (error != null) {
            print(' Channel subscription error: $error');
          } else {
            print('Successfully subscribed to notifications channel');
          }
        });

    return channel;
  }

  RealtimeChannel subscribeToUnreadMessages(
    String userId,
    Function(NotificationModel) onNewMessage,
  ) {
    final channel = _supabase.channel('unread_messages_$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'type',
            value: 'message',
          ),
          callback: (payload) {
            final data = payload.newRecord;
            if (data != null) {
              try {
                final notification = NotificationModel.fromJson(
                  Map<String, dynamic>.from(data),
                );
                onNewMessage(notification);
              } catch (e) {
                print('Error parsing notification: $e');
              }
            }
          },
        )
        .subscribe();

    return channel;
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select('count')
          .eq('user_id', userId)
          .eq('type', 'message')
          .eq('is_read', false);

      return response.first['count'] ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }
}
