import 'package:flutter/material.dart';

import '../database/database_service.dart';
import '../models/user.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // controllers for form fields
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // signup function
  Future<void> signupUser() async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // check if fields empty
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));

      return;
    }

    // create user object
    User user = User(username: username, email: email, password: password);

    // save user to database
    await DatabaseSevice.signup(user);

    if (!mounted) return;

    // show success message
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Account created")));

    // go back to login screen
    Navigator.pop(context);
  }

  // input field style
  InputDecoration input(String text) {
    return InputDecoration(
      labelText: text,

      labelStyle: const TextStyle(fontSize: 18),

      filled: true,

      fillColor: Colors.white,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: Color(0xFF61D4C0), width: 2),
      ),
    );
  }

  // main screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F7),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // app title
            const Text(
              "SPORTFIT",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29433E),
              ),
            ),

            const SizedBox(height: 12),

            // icon
            const Icon(
              Icons.fitness_center,
              size: 85,
              color: Color(0xFF61D4C0),
            ),

            const SizedBox(height: 12),

            // slogan
            const Text(
              "MAKES SURE YOU FIT",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 35),

            // signup card
            Container(
              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF61D4C0)),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  // username field
                  TextField(
                    controller: usernameController,

                    style: const TextStyle(fontSize: 18),

                    decoration: input("Username"),
                  ),

                  const SizedBox(height: 18),

                  // email field
                  TextField(
                    controller: emailController,

                    style: const TextStyle(fontSize: 18),

                    decoration: input("Email"),
                  ),

                  const SizedBox(height: 18),

                  // password field
                  TextField(
                    controller: passwordController,

                    obscureText: true,

                    style: const TextStyle(fontSize: 18),

                    decoration: input("Password"),
                  ),

                  const SizedBox(height: 22),

                  // create account button
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: signupUser,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF61D4C0),

                        foregroundColor: Colors.black,

                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),

                      child: const Text(
                        "Create Account",

                        style: TextStyle(
                          fontSize: 18,

                          fontWeight: FontWeight.bold,

                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // back to login button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Back to Sign In",

                      style: TextStyle(
                        fontSize: 17,

                        fontWeight: FontWeight.w600,

                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
