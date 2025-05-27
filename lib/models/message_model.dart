// // message.dart
// class Message {
//   final String id;
//   final String senderId;
//   final String content;
//   final String chatId; // Added chatId to the model
//   final DateTime createdAt;
//   final String status; // Added status to the model

//   Message({
//     required this.id,
//     required this.senderId,
//     required this.content,
//     required this.chatId,
//     required this.createdAt,
//     required this.status,
//   });

//  factory Message.fromJson(Map<String, dynamic> json) {
//   return Message(
//     id: json['id'] as String? ?? '',
//     chatId: json['chat_id'] as String? ?? '',
//     senderId: json['sender_id'] as String? ?? '',
//     content: json['content'] as String? ?? '',
//     createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
//     status: json['status'] as String? ?? 'sent',
//   );
// }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'sender_id': senderId,
//       'content': content,
//       'chat_id': chatId,
//       'created_at': createdAt.toIso8601String(),
//       'status': status,
//     };
//   }
// }

// // chat.dart
// class Chat {
//   final String id;
//   final String user1Id;
//   final String user2Id;
//   final DateTime createdAt;

//   Chat({
//     required this.id,
//     required this.user1Id,
//     required this.user2Id,
//     required this.createdAt,
//   });

//   factory Chat.fromJson(Map<String, dynamic> json) {
//     return Chat(
//       id: json['id'],
//       user1Id: json['user1_id'],
//       user2Id: json['user2_id'],
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
// }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      chatId: json['chat_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
    );
  }
}