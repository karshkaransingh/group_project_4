import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'weather_workout_screen.dart';

class SportsScreen extends StatefulWidget {
  final int userId;

  const SportsScreen({super.key, required this.userId});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  List<Map<String, dynamic>> sports = [];
  List<int> favoriteSportIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    sports = await DBHelper.getSports();

    List<Map<String, dynamic>> favorites = await DBHelper.getFavorites(
      widget.userId,
    );

    favoriteSportIds = favorites.map((item) => item['sportId'] as int).toList();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> toggleFavorite(int sportId) async {
    bool isFavorite = favoriteSportIds.contains(sportId);

    if (isFavorite) {
      await DBHelper.removeFavoriteBySportId(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.remove(sportId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from favorites")));
    } else {
      await DBHelper.addFavorite(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.add(sportId);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to favorites")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sports.isEmpty) {
      return const Center(child: Text("No sports available"));
    }

    return ListView.builder(
      itemCount: sports.length,
      itemBuilder: (context, index) {
        var sport = sports[index];
        bool isFavorite = favoriteSportIds.contains(sport['id']);

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(sport['name']),
            subtitle: Text(sport['description']),
            trailing: IconButton(
              onPressed: () async {
                await toggleFavorite(sport['id']);
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WeatherWorkoutScreen(
                    userId: widget.userId,
                    sportId: sport['id'],
                    sportName: sport['name'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
