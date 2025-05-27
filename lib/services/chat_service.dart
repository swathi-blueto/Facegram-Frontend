// import 'package:project/constants/api_constants.dart';
// import 'package:project/models/message_model.dart';
// import 'package:project/services/auth_service.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ChatService {
//   static Future<String> createChatIfNotExists(String user1, String user2) async {
//     try {
//       final token = await AuthService.getToken();
//       final response = await http.post(
//         Uri.parse(ApiConstants.createChat),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({'user1': user1, 'user2': user2}),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return jsonDecode(response.body)['chatId'];
//       }
//       throw Exception('Failed to create chat: ${response.body}');
//     } catch (e) {
//       throw Exception('Error creating chat: $e');
//     }
//   }

//   static Future<List<Message>> fetchMessages(String chatId) async {
//     try {
//       final token = await AuthService.getToken();
//       final response = await http.get(
//         Uri.parse(ApiConstants.getMessages.replaceFirst(':chatId', chatId)),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         if (responseBody is Map && responseBody.containsKey('messages')) {
//           final List<dynamic> messages = responseBody['messages'];
//           return messages.map((json) => Message.fromJson(json)).toList();
//         } else if (responseBody is List) {
//           return responseBody.map((json) => Message.fromJson(json)).toList();
//         }
//         throw Exception('Invalid response format');
//       }
//       throw Exception('Failed to fetch messages: ${response.statusCode}');
//     } catch (e) {
//       print(e);
//       throw Exception('Error fetching messages: $e');
//     }
//   }

//   static Future<Message> sendMessage(
//     String chatId, String senderId, String content) async {
//     try {
//       if (content.isEmpty) {
//         throw Exception('Message content cannot be empty');
//       }

//       final token = await AuthService.getToken();
//       final response = await http.post(
//         Uri.parse(ApiConstants.sendMessage.replaceFirst(':chatId', chatId)),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'sender_id': senderId,
//           'content': content,
//           'chatId': chatId, // Make sure this is included
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body);
//         return Message.fromJson(responseBody);
//       }
//       throw Exception('Failed to send message: ${response.statusCode}');
//     } catch (e) {
//       throw Exception('Error sending message: $e');
//     }
//   }

//   static Future<void> deleteMessage(String messageId) async {
//     try {
//       final token = await AuthService.getToken();
//       final response = await http.delete(
//         Uri.parse(ApiConstants.deleteMessage.replaceFirst(':messageId', messageId)),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to delete message');
//       }
//     } catch (e) {
//       throw Exception('Error deleting message: $e');
//     }
//   }

// static RealtimeChannel subscribeToMessages(
//   String chatId,
//   Function(Message) onMessageReceived,
// ) {
//   // Create a dedicated channel for this chat
//   final channel = Supabase.instance.client.channel('messages_$chatId');

//   // Set up the subscription
//   channel.on(
//     RealtimeListenTypes.postgresChanges,
//     ChannelFilter(
//       event: 'INSERT',
//       schema: 'public',
//       table: 'messages',
//       filter: 'chat_id=eq.$chatId',
//     ),
//     (payload, [ref]) {
//       final data = payload.newRecord;
//       if (data != null &&
//           data['content'] != null &&
//           data['content'].toString().isNotEmpty) {
//         try {
//           final message = Message.fromJson(Map<String, dynamic>.from(data));
//           onMessageReceived(message);
//         } catch (e) {
//           print('Error parsing message: $e');
//         }
//       }
//     },
//   ).subscribe();

//   return channel;
// }

// }




import 'package:flutter/foundation.dart';
import 'package:project/constants/api_constants.dart';
import 'package:project/models/message_model.dart';
import 'package:project/models/notification_model.dart';
import 'package:project/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static Future<String> createChatIfNotExists(
    String user1,
    String user2,
  ) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.createChat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user1': user1, 'user2': user2}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['chatId'];
      }
      throw Exception('Failed to create chat: ${response.body}');
    } catch (e) {
      throw Exception('Error creating chat: $e');
    }
  }

  static Future<List<Message>> fetchMessages(String chatId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(ApiConstants.getMessages.replaceFirst(':chatId', chatId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody is Map && responseBody.containsKey('messages')) {
          final List<dynamic> messages = responseBody['messages'];
          return messages.map((json) => Message.fromJson(json)).toList();
        } else if (responseBody is List) {
          return responseBody.map((json) => Message.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to fetch messages: ${response.statusCode}');
    } catch (e) {
      print(e);
      throw Exception('Error fetching messages: $e');
    }
  }

  static Future<Message> sendMessage(
    String chatId,
    String senderId,
    String content,
  ) async {
    try {
      if (content.isEmpty) {
        throw Exception('Message content cannot be empty');
      }

      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse(ApiConstants.sendMessage.replaceFirst(':chatId', chatId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sender_id': senderId,
          'content': content,
          'chatId': chatId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return Message.fromJson(responseBody);
      }
      throw Exception('Failed to send message: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse(
          ApiConstants.deleteMessage.replaceFirst(':messageId', messageId),
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  static RealtimeChannel subscribeToMessages(
    String chatId,
    Function(Message) onMessageReceived,
  ) {
    final channel = Supabase.instance.client.channel('messages_$chatId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            
            final data = payload.newRecord;
            if (data != null &&
                data['content'] != null &&
                data['content'].toString().isNotEmpty) {
              try {
                final message = Message.fromJson(
                  Map<String, dynamic>.from(data),
                );
                onMessageReceived(message);
              } catch (e) {
                print('Error parsing message: $e');
              }
            }
          },
        )
        .subscribe();

    return channel;
  }
}
