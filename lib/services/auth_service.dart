import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/constants/api_constants.dart';

class AuthService {


   static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse(ApiConstants.login);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userId', data['id']);
      await prefs.setString('role', data['role'] ?? 'user'); // Store the role

      return data;
    } else {
      final error = jsonDecode(response.body);
      print(error);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

static Future<Map<String, dynamic>> signup(
  String firstName,
  String lastName,
  String email,
  String password,
) async {
  try {
    final url = Uri.parse(ApiConstants.register);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      
      if (responseBody['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseBody['token']);
        await prefs.setString('userId', responseBody['id']);
        await prefs.setString('role', responseBody['role'] ?? 'user');
      }
      return responseBody;
    } else {
      throw Exception(responseBody['message'] ?? 'Signup failed');
    }
  } on http.ClientException catch (e) {
    throw Exception('Network error: ${e.message}');
  } on FormatException {
    throw Exception('Invalid server response');
  } catch (e) {
    throw Exception('Signup failed: ${e.toString()}');
  }
}

  static Future<Map<String, dynamic>> logout() async {
    final url = Uri.parse(ApiConstants.logout);
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Logout failed');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

   static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}


