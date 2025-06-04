import 'dart:io';
import 'package:project/constants/api_constants.dart';
import 'package:project/services/auth_service.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';

class PostService {
  static Future<void> _handleTokenExpiration(http.Response response) async {
    if (response.statusCode == 401) {
     
      await AuthService.logout();
      throw Exception('Session expired. Please log in again.');
    }
  }

static Future<List<dynamic>> getPosts() async {
  try {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final currentUserId = await AuthService.getCurrentUserId();
    if (currentUserId == null) {
      throw Exception('Unable to get current user ID');
    }

    final url = Uri.parse(ApiConstants.getPosts);
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 401) {
      await AuthService.logout();
      throw Exception('Session expired. Please log in again.');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch posts: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    
    if (data['data'] is! List) {
      throw Exception('Invalid response format');
    }

    return data['data'] as List<dynamic>;
  } on http.ClientException catch (e) {
    throw Exception('Network error: ${e.message}');
  } on FormatException catch (e) {
    throw Exception('Invalid JSON format: ${e.message}');
  } catch (e) {
    throw Exception('Failed to get posts: ${e.toString()}');
  }
}

  static Future<List<dynamic>> getPostsById(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No token found. User may not be logged in.');
        return [];
      }

      final url = Uri.parse(ApiConstants.getPostsById.replaceFirst(":id", userId));
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token" 
        },
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic>) {
          return [data]; 
        }
        return [];
      } else {
        print('Failed to load post: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching post by ID: $e');
      return [];
    }
  }

  static Future<bool> likeOrUnlikePost(String postId, bool isLiked) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No token found. User may not be logged in.');
        return false;
      }

      final url = Uri.parse(ApiConstants.likePost.replaceFirst(':id', postId));
      
      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) return false;

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': currentUserId,
        }),
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to like post. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> addComment(
      String postId, String text) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No token found. User may not be logged in.');
        return null;
      }

      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) return null;

      final url = Uri.parse(ApiConstants.commentPost.replaceFirst(':postId', postId));

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'commentText': text,
          'userId': currentUserId,
        }),
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Failed to add comment. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print("Error posting comment: $e");
      return null;
    }
  }

  static Future<List<dynamic>> getComments(String postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('No token found. User may not be logged in.');
        return [];
      }

      final url = Uri.parse(ApiConstants.getComments.replaceFirst(':postId', postId));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        print('Failed to fetch comments. Status: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  static Future<dynamic> deleteComment(String commentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return null;

      final currentUserId = await AuthService.getCurrentUserId();
      if (currentUserId == null) return null;

      final url = Uri.parse(
          ApiConstants.deleteCommentById.replaceFirst(":commentId", commentId));
          
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': currentUserId,
        }),
      );

      await _handleTokenExpiration(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to delete comment. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("Error deleting comment: $e");
      return null;
    }
  }


  
static Future<void> createPost({
  required String userId,
  required String content,
  required String visibility,
  File? imageFile,
}) async {
  try {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse(ApiConstants.createPost);
    
   
    var request = http.MultipartRequest('POST', url);
    
    
    request.headers['Authorization'] = 'Bearer $token';
    
   
    request.fields['user_id'] = userId;
    request.fields['content'] = content;
    request.fields['visibility'] = visibility;
    
   
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image_file',
        imageFile.path,
      ));
    }
    
  
    request.fields['data'] = jsonEncode({
      'user_id': userId,
      'content': content,
      'visibility': visibility,
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception('Failed to create post: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    throw Exception('Error creating post: ${e.toString()}');
  }
}
}
