import 'package:flutter/material.dart';

import '../database/database_service.dart';
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
    sports = await DatabaseSevice.getSports();

    List<Map<String, dynamic>> favorites = await DatabaseSevice.getFavorites(
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
      await DatabaseSevice.removeFavoriteBySportId(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.remove(sportId);
      });
    } else {
      await DatabaseSevice.addFavorite(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.add(sportId);
      });
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
      padding: const EdgeInsets.all(16),
      itemCount: sports.length,
      itemBuilder: (context, index) {
        final sport = sports[index];
        final bool isFavorite = favoriteSportIds.contains(sport['id']);
        final String imagePath = sport['image'];

        return GestureDetector(
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
          child: Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.black.withOpacity(0.35),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        sport['name'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await toggleFavorite(sport['id']);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
