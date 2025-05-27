import 'dart:convert';
import 'package:project/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/constants/api_constants.dart';
import 'package:project/services/auth_service.dart';

class FriendService {
  static Future<bool> sendFriendRequest(String receiverId) async {
    try {
      final url = Uri.parse(
          ApiConstants.sendFriendRequest.replaceFirst(':userId', receiverId));
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) return true;

      print('Send request failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error sending friend request: $e');
      return false;
    }
  }

  static Future<bool> acceptFriendRequest(String receiverId) async {
    try {
      final url = Uri.parse(
          ApiConstants.acceptFriendRequest.replaceFirst(":userId", receiverId));
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) return true;

      print('Accept request failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  static Future<bool> cancelFriendRequest(String receiverId) async {
    try {
      final url = Uri.parse(
          ApiConstants.cancelFriendRequest.replaceFirst(":userId", receiverId));
      final token = await AuthService.getToken();
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) return true;

      print('Cancel request failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error canceling friend request: $e');
      return false;
    }
  }

  static Future<bool> removeFriend(String userId, String friendId) async {
    try {
      final url = Uri.parse(ApiConstants.removeFriend);
      final token = await AuthService.getToken();
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'friendId': friendId,
        }),
      );

      if (response.statusCode == 200) return true;

      print('Remove friend failed: ${response.body}');
      return false;
    } catch (e) {
      print('Error removing friend: $e');
      return false;
    }
  }

  static Future<List<PotentialFriend>> getPotentialFriends(
      String userId) async {
    try {
      final url = Uri.parse(ApiConstants.getPotentialFriends);
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            return (responseData['data'] as List)
                .map((json) =>
                    PotentialFriend.fromJson(json as Map<String, dynamic>))
                .toList();
          } else {
            return [
              PotentialFriend.fromJson(responseData.cast<String, dynamic>())
            ];
          }
        } else if (responseData is List) {
          return responseData
              .map((json) =>
                  PotentialFriend.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        throw Exception(
            'Unexpected response format: ${responseData.runtimeType}');
      }

      throw Exception(
          'Failed to load potential friends: ${response.statusCode}');
    } catch (e) {
      print('Error getting potential friends: $e');
      rethrow;
    }
  }

  static Future<List<PotentialFriend>> getPendingFriendRequests(
      String userId) async {
    try {
      final url = Uri.parse(ApiConstants.getPendingFriendRequests);
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return (responseData['data'] as List)
              .map((json) =>
                  PotentialFriend.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (responseData is List) {
          return responseData
              .map((json) =>
                  PotentialFriend.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception(
            'Failed to load pending requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting pending requests: $e');
      rethrow;
    }
  }

  static Future<List<PotentialFriend>> getReceivedFriendRequests(
      String userId) async {
    try {
      final url = Uri.parse(ApiConstants.getReceivedFriendRequests);
      final token = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return (responseData['data'] as List)
              .map((json) =>
                  PotentialFriend.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (responseData is List) {
          return responseData
              .map((json) =>
                  PotentialFriend.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception(
            'Failed to load received requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting received requests: $e');
      rethrow;
    }
  }

  static Future<List<PotentialFriend>> getFriends(String userId) async {
  try {
    final url = Uri.parse(ApiConstants.getFriends);
    final token = await AuthService.getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return (responseData['data'] as List)
            .where((friend) => friend['id'] != userId) // Filter out current user
            .map((json) => PotentialFriend.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (responseData is List) {
        return responseData
            .where((friend) => friend['id'] != userId) // Filter out current user
            .map((json) => PotentialFriend.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else if (response.statusCode == 403) {
      throw Exception('Access denied. You do not have permission to view this resource.');
    } else {
      print('Failed to load accepted requests: ${response.body}');
      throw Exception('Failed to load accepted requests: ${response.statusCode}');
    }
  } catch (e) {
    print('Error getting accepted requests: $e');
    rethrow;
  }
}
}
