import 'package:flutter/material.dart';

import '../main.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'sports_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final int initialIndex;

  const HomeScreen({super.key, required this.userId, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int selectedIndex;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.initialIndex;

    pages = [
      SportsScreen(userId: widget.userId),

      FavoritesScreen(userId: widget.userId),

      HistoryScreen(userId: widget.userId),

      ProgressScreen(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorbg,

      appBar: AppBar(
        backgroundColor: const Color(0xFFD4F24C),

        title: Text(
          "SPORTFIT",

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              isDarkMode.value = !isDarkMode.value;
            },

            icon: Icon(
              isDarkMode.value ? Icons.light_mode : Icons.dark_mode,

              color: colortxt,
            ),
          ),
        ],
      ),

      body: pages[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorbg,

        selectedItemColor: Colors.black,

        unselectedItemColor: Colors.grey,

        currentIndex: selectedIndex,

        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: "Sports",
            backgroundColor: Color(0xFFD4F24C),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
            backgroundColor: Color(0xFFD4F24C),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            backgroundColor: Color(0xFFD4F24C),
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Progress",
            backgroundColor: Color(0xFFD4F24C),
          ),
        ],
      ),
    );
  }
}
