import 'package:flutter/material.dart';

import 'database/database_service.dart';
import 'screens/splash_screen.dart';

// dark mode toggle variable
ValueNotifier<bool> isDarkMode = ValueNotifier(false);

// background color based on theme
Color get colorbg => isDarkMode.value ? Colors.black : Colors.white;

// text color based on theme
Color get colortxt => isDarkMode.value ? Colors.white : Colors.black;

// app entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensure flutter ready

  await DatabaseSevice.getDatabase(); // initialize database

  runApp(const MyApp());
}

// main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // rebuild app when theme changes
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,

      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          home: const SplashScreen(), // first screen
        );
      },
    );
  }
}
