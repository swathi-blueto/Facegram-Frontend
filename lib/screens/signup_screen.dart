import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth/curved_clipper.dart';
import '../widgets/auth/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleSignup() async {
    final firstName = firstNameController.text;
    final lastName = lastNameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    try {
     
      await AuthService.signup(firstName, lastName, email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup Successful")),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: $e")),
      );
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

                CustomTextField(controller: firstNameController, label: "First Name"),
                CustomTextField(controller: lastNameController, label: "Last Name"),
                CustomTextField(controller: emailController, label: "Email"),
                CustomTextField(controller: passwordController, label: "Password", isPassword: true),

                const SizedBox(height: 40),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: handleSignup,
                    child: const Text("Sign up", style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text("Already have an account? Login"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
