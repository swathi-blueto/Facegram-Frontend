import "package:project/constants/api_constants.dart";
import "package:project/models/user_profile.dart";
import "package:project/services/auth_service.dart";
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'dart:io';


class UserService {
Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
  try {
    final token = await AuthService.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiConstants.fetchUserDetails.replaceFirst("userId", userId)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    debugPrint('Error fetching profile: $e');
    return null;
  }
}

  Future<UserProfile?> createUserProfile(
    String userId,
    Map<String, dynamic> profileData,
    File? profileImage,
    File? coverImage,
  ) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. User may not be logged in.');
      }

      final url = Uri.parse(
          ApiConstants.editUserProfile.replaceFirst(':userId', userId));
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';

      final Map<String, String> requestFields = {
        'phone': profileData['phone']?.toString() ?? '',
        'gender': profileData['gender']?.toString() ?? '',
        'date_of_birth': profileData['date_of_birth']?.toString() ?? '',
        'city': profileData['city']?.toString() ?? '',
        'country': profileData['country']?.toString() ?? '',
        'hometown': profileData['hometown']?.toString() ?? '',
        'bio': profileData['bio']?.toString() ?? '',
        'work': profileData['work']?.toString() ?? '',
        'education': profileData['education']?.toString() ?? '',
        'relationship_status':
            profileData['relationship_status']?.toString() ?? '',
      };

      

      request.fields.addAll(requestFields);

      if (profileImage != null) {
       
        request.files.add(await http.MultipartFile.fromPath(
          'profile_pic',
          profileImage.path,
        ));
      }

      if (coverImage != null) {
        
        request.files.add(await http.MultipartFile.fromPath(
          'cover_photo',
          coverImage.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

    

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = jsonDecode(responseBody);
          return UserProfile.fromJson(jsonResponse);
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        String errorMessage =
            'Failed to update profile: ${response.statusCode}';
        try {
          final errorJson = jsonDecode(responseBody);
          errorMessage +=
              ' - ${errorJson['error'] ?? errorJson['message'] ?? responseBody}';
        } catch (_) {
          errorMessage += ' - $responseBody';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error in createUserProfile: $e');
      rethrow;
    }
  }
}
