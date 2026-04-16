import 'dart:async';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // start timer and navigate to login screen
  @override
  void initState() {
    super.initState();

    // wait 5 seconds then open login screen
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  // main splash UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // center content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // app icon
            Icon(Icons.fitness_center, size: 90, color: Color(0xFF61D4C0)),

            SizedBox(height: 20),

            // app title
            Text(
              "SPORTFIT",

              style: TextStyle(
                fontSize: 34,

                fontWeight: FontWeight.bold,

                color: Color(0xFF29433E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
