import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/database_service.dart';
import '../widgets/favorite_card.dart';
import 'home_screen.dart';
import 'weather_workout_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final int userId;

  const FavoritesScreen({super.key, required this.userId});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    favorites = await DatabaseSevice.getFavorites(widget.userId);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeFavorite(int favoriteId) async {
    await DatabaseSevice.deleteFavorite(favoriteId);
    await loadFavorites();

    if (!mounted) return;
  }

  Widget buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colortxt,
                ),
                child: Icon(Icons.favorite_border, size: 58, color: colorbg),
              ),
              const SizedBox(height: 28),
              Text(
                "No Favorites Yet",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colortxt,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                "Add sports to your favorites from the home screen to quickly access them here",
                style: TextStyle(fontSize: 20, color: colortxt, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(userId: widget.userId, initialIndex: 0),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorbg,
                  side: BorderSide(color: colortxt),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Browse Sports",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colortxt,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: colorbg,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: loadFavorites,
              child: favorites.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Favorite Sports",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: colortxt,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${favorites.length} sports saved",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: colortxt,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 70),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: buildEmptyState(),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 34,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Favorite Sports",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: colortxt,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${favorites.length} sports saved",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: colortxt,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ...favorites.map(
                          (favorite) => FavoriteCard(
                            favorite: favorite,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WeatherWorkoutScreen(
                                    userId: widget.userId,
                                    sportId: favorite['sportId'],
                                    sportName: favorite['name'],
                                  ),
                                ),
                              );
                            },
                            onDelete: () async {
                              await removeFavorite(favorite['id']);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
