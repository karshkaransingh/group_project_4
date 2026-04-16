import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import 'home_screen.dart';

class WorkoutCompletedScreen extends StatelessWidget {
  final int userId;
  final String sportName;
  final int completedExercises;

  const WorkoutCompletedScreen({
    super.key,
    required this.userId,
    required this.sportName,
    required this.completedExercises,
  });

  // main screen UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorbg,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // trophy icon circle
                Container(
                  width: 130,

                  height: 130,

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(
                      colors: [Color(0xFFD4F24C), Color(0xFF61D4C0)],

                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: const Icon(
                    Icons.emoji_events_outlined,

                    color: Colors.white,

                    size: 64,
                  ),
                ),

                const SizedBox(height: 24),

                // completion title
                Text(
                  "Workout Complete!",

                  style: TextStyle(
                    fontSize: 34,

                    fontWeight: FontWeight.bold,

                    color: colortxt,
                  ),

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                // motivational text
                const Text(
                  "You crushed it! Your dedication shows!",

                  style: TextStyle(fontSize: 20, color: Colors.grey),

                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // stats card
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 24,
                  ),

                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 41, 41, 41),

                    borderRadius: BorderRadius.circular(18),

                    border: Border.all(color: Colors.white12),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      // exercise count
                      Column(
                        children: [
                          Text(
                            completedExercises.toString(),

                            style: const TextStyle(
                              fontSize: 32,

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF61D4C0),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Exercises",

                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),

                      // divider line
                      Container(width: 1, height: 60, color: Colors.white12),

                      // sport name
                      Column(
                        children: [
                          Text(
                            sportName,

                            style: const TextStyle(
                              fontSize: 26,

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF61D4C0),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Sport",

                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // motivational quote card
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(
                      color: const Color(0xFFD4F24C).withOpacity(0.25),
                    ),
                  ),

                  child: const Text(
                    '"The only bad workout is the one that didn\'t happen. You showed up and gave it your all!"',

                    textAlign: TextAlign.center,

                    style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                  ),
                ),

                const SizedBox(height: 26),

                // button to open progress screen
                SizedBox(
                  width: double.infinity,

                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            userId: userId,

                            initialIndex: 3, // open progress tab
                          ),
                        ),
                      );
                    },

                    icon: const Icon(Icons.trending_up),

                    label: const Text(
                      "View Progress",

                      style: TextStyle(fontSize: 17),
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF61D4C0),

                      foregroundColor: Colors.white,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // button to go home
                SizedBox(
                  width: double.infinity,

                  height: 52,

                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,

                        MaterialPageRoute(
                          builder: (context) => HomeScreen(userId: userId),
                        ),
                      );
                    },

                    icon: const Icon(Icons.home_outlined),

                    label: const Text(
                      "Back to Home",

                      style: TextStyle(fontSize: 17),
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,

                      backgroundColor: Colors.grey,

                      side: const BorderSide(color: Colors.white12),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
