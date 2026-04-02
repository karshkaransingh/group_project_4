import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'sports_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

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
      appBar: AppBar(title: const Text("SportFit"), centerTitle: true),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
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
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Progress",
            backgroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
