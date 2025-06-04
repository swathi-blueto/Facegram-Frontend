
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import '../widgets/auth/curved_clipper.dart';
import '../widgets/auth/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _toast = FToast();

  @override
  void initState() {
    super.initState();
    _toast.init(context);
  }

void _showToast(String message, {bool isError = false}) {
  _toast.removeQueuedCustomToasts();
  _toast.showToast(
    child: Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9, 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isError ? Colors.red : Colors.blueAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
            size: 24, 
          ),
          const SizedBox(width: 12),
          Flexible( 
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              overflow: TextOverflow.ellipsis, 
            ),
          ),
        ],
      ),
    ),
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 3),
  );
}

 void handleLogin() async {
  final email = emailController.text;
  final password = passwordController.text;

  try {
    final response = await AuthService.login(email, password);
    final role = response['role'] ?? 'user';

    _showToast("Login Successful");

    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  } catch (e) {
   
    _showToast(e.toString(), isError: true);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DoubleCurvedHeader(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/signup'),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(controller: emailController, label: "E-mail"),
                CustomTextField(
                  controller: passwordController,
                  label: "Password",
                  isPassword: true,
                ),
                const SizedBox(height: 80),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: handleLogin,
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text("I'm already a member"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}