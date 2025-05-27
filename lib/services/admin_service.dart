import 'package:project/constants/api_constants.dart';
import 'package:project/models/user_profile.dart';
import 'package:project/models/post_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project/services/auth_service.dart';

class AdminService {
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => UserProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in getAllUsers: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId/block'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to block user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in blockUser: $e');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId/unblock'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to unblock user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in unblockUser: $e');
    }
  }

Future<List<PostModel>> getAllPosts() async {
  try {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No token found. User may not be logged in.');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/admin/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error in getAllPosts: $e');
  }
}

  Future<void> deletePost(String postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/admin/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in deletePost: $e');
    }
  }
}