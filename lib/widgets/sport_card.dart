import 'package:flutter/material.dart';

// reusable card for sport display
class SportCard extends StatelessWidget {
  final Map<String, dynamic> sport;

  final bool isFavorite;

  final VoidCallback onTap;

  final VoidCallback onFavoriteToggle;

  const SportCard({
    super.key,
    required this.sport,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  // main card UI
  @override
  Widget build(BuildContext context) {
    // get sport image path
    final String imagePath = sport['image'];

    return GestureDetector(
      onTap: onTap, // open workout screen

      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 18),

        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),

          child: Stack(
            fit: StackFit.expand,

            children: [
              // sport image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,

                // fallback if image missing
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF29433E),

                    child: const Center(
                      child: Icon(Icons.sports, color: Colors.white, size: 40),
                    ),
                  );
                },
              ),

              // dark overlay (UNCHANGED)
              Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withOpacity(0.35),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // sport name
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

                    // favorite icon button
                    IconButton(
                      onPressed: onFavoriteToggle,

                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,

                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
