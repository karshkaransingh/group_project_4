import 'package:flutter/material.dart';

// reusable card for favorite item
class FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favorite;

  final VoidCallback onTap;

  final VoidCallback onDelete;

  const FavoriteCard({
    super.key,

    required this.favorite,

    required this.onTap,

    required this.onDelete,
  });

  // main card UI
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // open workout

      child: Container(
        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(color: const Color(0xFFFF5A5F)),
        ),

        child: Row(
          children: [
            // favorite icon circle
            Container(
              width: 64,

              height: 64,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,

                color: Color(0xFFFF5A5F),
              ),

              child: const Icon(Icons.favorite, color: Colors.white, size: 30),
            ),

            const SizedBox(width: 16),

            // text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // favorite name
                  Text(
                    favorite['name'],

                    style: const TextStyle(
                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // description
                  Text(
                    favorite['description'],

                    style: const TextStyle(
                      fontSize: 16,

                      color: Colors.grey,

                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // delete button
            IconButton(
              onPressed: onDelete, // remove favorite

              icon: const Icon(
                Icons.delete_outline,

                color: Colors.redAccent,

                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
