import 'dart:async';
import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // timer to control splash duration
  Timer? splashTimer;

  // start timer when screen loads
  @override
  void initState() {
    super.initState();

    // wait 5 seconds then navigate to login screen
    splashTimer = Timer(const Duration(seconds: 5), () {
      // check if screen still exists before navigating
      if (!mounted) return;

      // replace splash with login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  // cancel timer when splash screen is removed
  @override
  void dispose() {
    splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // app icon
            Icon(Icons.fitness_center, size: 90, color: Color(0xFF61D4C0)),

            SizedBox(height: 20),

            // app title text
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
