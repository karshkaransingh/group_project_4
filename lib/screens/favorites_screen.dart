import 'package:flutter/material.dart';

import '../database/db_helper.dart';

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
    favorites = await DBHelper.getFavorites(widget.userId);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> removeFavorite(int favoriteId) async {
    await DBHelper.deleteFavorite(favoriteId);
    await loadFavorites();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Favorite removed")));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadFavorites,
        child: ListView(
          children: const [
            SizedBox(height: 250),
            Center(child: Text("No favorite sports yet")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadFavorites,
      child: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          var favorite = favorites[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(favorite['name']),
              subtitle: Text(favorite['description']),
              trailing: IconButton(
                onPressed: () async {
                  await removeFavorite(favorite['id']);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          );
        },
      ),
    );
  }
}
