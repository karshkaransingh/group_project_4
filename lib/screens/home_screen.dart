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
  // current selected tab index
  late int selectedIndex;

  // list of screens for bottom navigation
  late List<Widget> pages;

  // initialize selected tab and pages
  @override
  void initState() {
    super.initState();

    selectedIndex = widget.initialIndex; // set starting tab

    pages = [
      SportsScreen(userId: widget.userId),

      FavoritesScreen(userId: widget.userId),

      HistoryScreen(userId: widget.userId),

      ProgressScreen(userId: widget.userId),
    ];
  }

  // main screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorbg,

      // top app bar
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4F24C),

        title: Text(
          "SPORTFIT",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        centerTitle: true,

        // dark mode toggle button
        actions: [
          IconButton(
            onPressed: () {
              isDarkMode.value = !isDarkMode.value; // toggle theme
            },

            icon: Icon(
              isDarkMode.value ? Icons.light_mode : Icons.dark_mode,

              color: colortxt,
            ),
          ),
        ],
      ),

      // display selected page
      body: pages[selectedIndex],

      // bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colorbg,

        selectedItemColor: Colors.black,

        unselectedItemColor: Colors.grey,

        currentIndex: selectedIndex,

        // change tab
        onTap: (value) {
          setState(() {
            selectedIndex = value; // update selected tab
          });
        },

        items: const [
          // sports tab
          BottomNavigationBarItem(
            icon: Icon(Icons.sports),
            label: "Sports",
            backgroundColor: Color(0xFFD4F24C),
          ),

          // favorites tab
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
            backgroundColor: Color(0xFFD4F24C),
          ),

          // history tab
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            backgroundColor: Color(0xFFD4F24C),
          ),

          // progress tab
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
