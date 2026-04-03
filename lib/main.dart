import 'package:flutter/material.dart';

import 'database/db_helper.dart';
import 'screens/splash_screen.dart';

ValueNotifier<bool> isDarkMode = ValueNotifier(true);

// white in dark mode, black in light mode
Color colorwb = Colors.white;

// black in dark mode, white in light mode
Color colorbw = Colors.black;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper.getDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,

      builder: (context, value, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          home: const SplashScreen(),
        );
      },
    );
  }
}
