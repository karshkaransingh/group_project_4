import 'package:flutter/material.dart';

import 'database/database_service.dart';
import 'screens/splash_screen.dart';

ValueNotifier<bool> isDarkMode = ValueNotifier(false);

Color get colorbg => isDarkMode.value ? Colors.black : const Color(0xFFF5F7F7);

Color get colortxt => isDarkMode.value ? Colors.white : Colors.black;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseSevice.getDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
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
