import 'package:flutter/material.dart';

import '../database/database_service.dart';
import '../widgets/sport_card.dart';
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

  // load sports and favorites on start
  @override
  void initState() {
    super.initState();
    loadData();
  }

  // fetch sports and favorite ids
  Future<void> loadData() async {
    sports = await DatabaseSevice.getSports();

    List<Map<String, dynamic>> favorites = await DatabaseSevice.getFavorites(
      widget.userId,
    );

    // store favorite sport ids
    favoriteSportIds = favorites.map((item) => item['sportId'] as int).toList();

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // add or remove favorite
  Future<void> toggleFavorite(int sportId) async {
    bool isFavorite = favoriteSportIds.contains(sportId);

    // remove favorite
    if (isFavorite) {
      await DatabaseSevice.removeFavoriteBySportId(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.remove(sportId);
      });
    }
    // add favorite
    else {
      await DatabaseSevice.addFavorite(widget.userId, sportId);

      if (!mounted) return;

      setState(() {
        favoriteSportIds.add(sportId);
      });
    }
  }

  // main screen UI
  @override
  Widget build(BuildContext context) {
    // loading state
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // no sports available
    if (sports.isEmpty) {
      return const Center(child: Text("No sports available"));
    }

    // list of sport cards
    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: sports.length,

      itemBuilder: (context, index) {
        final sport = sports[index];

        final bool isFavorite = favoriteSportIds.contains(sport['id']);

        return SportCard(
          sport: sport,

          isFavorite: isFavorite,

          // open workout screen
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

          // toggle favorite icon
          onFavoriteToggle: () async {
            await toggleFavorite(sport['id']);
          },
        );
      },
    );
  }
}
