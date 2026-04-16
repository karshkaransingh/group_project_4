import 'package:flutter/material.dart';

// reusable card for sport progress display
class ProgressCard extends StatelessWidget {
  final Map<String, dynamic> item;

  final IconData icon;

  const ProgressCard({super.key, required this.item, required this.icon});

  // main card UI
  @override
  Widget build(BuildContext context) {
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
              // sport icon circle
              Container(
                width: 62,

                height: 62,

                decoration: const BoxDecoration(
                  shape: BoxShape.circle,

                  gradient: LinearGradient(
                    colors: [Color(0xFF61D4C0), Color(0xFFD4F24C)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),
                ),

                child: Icon(icon, color: Colors.white, size: 30),
              ),

              const SizedBox(width: 16),

              // sport name and count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // sport name
                    Text(
                      item['sportName'],

                      style: const TextStyle(
                        fontSize: 19,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // completed vs total exercises
                    Text(
                      "${item['completed']} / ${item['total']} exercises",

                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),

              // percentage text
              Text(
                "${(item['percent'] as double).toStringAsFixed(0)}%",

                style: const TextStyle(
                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                  color: Color(0xFF61D4C0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: LinearProgressIndicator(
              minHeight: 10,

              // calculate progress value
              value: item['total'] == 0 ? 0 : item['completed'] / item['total'],

              backgroundColor: const Color(0xFF29433E),

              valueColor: const AlwaysStoppedAnimation(Color(0xFF61D4C0)),
            ),
          ),
        ],
      ),
    );
  }
}
