import 'package:flutter/material.dart';

// reusable card for workout history item
class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;

  final String durationText;

  final String timeText;

  final IconData icon;

  final VoidCallback onDelete;

  const HistoryCard({
    super.key,

    required this.item,

    required this.durationText,

    required this.timeText,

    required this.icon,

    required this.onDelete,
  });

  // main card UI
  @override
  Widget build(BuildContext context) {
    // determine style label based on workout type
    String styleName = item['type'] == "outdoor"
        ? "Athletic Style"
        : "Home Style";

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: Colors.black),
      ),

      child: Column(
        children: [
          Row(
            children: [
              // icon circle
              Container(
                width: 62,

                height: 62,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: const LinearGradient(
                    colors: [Color(0xFF61D4C0), Color(0xFFD4F24C)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),
                ),

                child: Icon(icon, color: Colors.white, size: 30),
              ),

              const SizedBox(width: 16),

              // text details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // exercise name
                    Text(
                      item['exerciseName'],

                      style: const TextStyle(
                        fontSize: 19,

                        fontWeight: FontWeight.bold,

                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // sport and style
                    Text(
                      "${item['sportName']} • $styleName",

                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),

                    const SizedBox(height: 4),

                    // duration row
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,

                          size: 16,

                          color: Colors.black,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          durationText,

                          style: const TextStyle(
                            fontSize: 16,

                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // delete button
              TextButton.icon(
                onPressed: onDelete, // remove history item

                icon: const Icon(Icons.delete_outline, color: Colors.red),

                label: const Text(
                  "Delete",

                  style: TextStyle(
                    color: Colors.red,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // time text
          Align(
            alignment: Alignment.centerLeft,

            child: Text(
              timeText,

              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
