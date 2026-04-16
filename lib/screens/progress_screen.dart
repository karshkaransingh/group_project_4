import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/database_service.dart';
import '../widgets/progress_card.dart';

class ProgressScreen extends StatefulWidget {
  final int userId;

  const ProgressScreen({super.key, required this.userId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> sports = [];
  List<Map<String, dynamic>> progressData = [];
  bool isLoading = true;

  // load progress on start
  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  // fetch sports and calculate progress
  Future<void> loadProgress() async {
    sports = await DatabaseSevice.getSports();

    progressData = [];

    // loop through each sport
    for (int i = 0; i < sports.length; i++) {
      int sportId = sports[i]['id'];

      int totalExercises = await DatabaseSevice.getTotalExercisesCount(sportId);

      int completedExercises = await DatabaseSevice.getCompletedExercisesCount(
        widget.userId,
        sportId,
      );

      double percent = 0;

      // avoid divide by zero
      if (totalExercises > 0) {
        percent = (completedExercises / totalExercises) * 100;
      }

      // store progress info
      progressData.add({
        'sportId': sportId,
        'sportName': sports[i]['name'],
        'completed': completedExercises,
        'total': totalExercises,
        'percent': percent,
      });
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  // total completed exercises
  int getOverallCompleted() {
    int total = 0;

    for (int i = 0; i < progressData.length; i++) {
      total += progressData[i]['completed'] as int;
    }

    return total;
  }

  // total available exercises
  int getOverallExercises() {
    int total = 0;

    for (int i = 0; i < progressData.length; i++) {
      total += progressData[i]['total'] as int;
    }

    return total;
  }

  // calculate overall completion percentage
  double getAverageCompletion() {
    int overallTotal = getOverallExercises();

    int overallCompleted = getOverallCompleted();

    if (overallTotal == 0) return 0;

    return (overallCompleted / overallTotal) * 100;
  }

  // return sport icon
  IconData getSportIcon(String sportName) {
    switch (sportName.toLowerCase()) {
      case "basketball":
        return Icons.sports_basketball_outlined;

      case "soccer":
        return Icons.sports_soccer_outlined;

      case "tennis":
        return Icons.sports_tennis_outlined;

      default:
        return Icons.fitness_center_outlined;
    }
  }

  // main screen UI
  @override
  Widget build(BuildContext context) {
    // loading screen
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,

      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: colorbg,

          body: SafeArea(
            // pull to refresh progress
            child: RefreshIndicator(
              onRefresh: loadProgress,

              child: ListView(
                padding: const EdgeInsets.all(18),

                children: [
                  // header section
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // title
                            Text(
                              "Your Progress",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: colortxt,
                              ),
                            ),

                            SizedBox(height: 4),

                            // subtitle
                            Text(
                              "Track your journey",
                              style: TextStyle(fontSize: 18, color: colortxt),
                            ),
                          ],
                        ),
                      ),

                      // refresh button
                      IconButton(
                        onPressed: loadProgress,

                        icon: Icon(Icons.refresh, color: colortxt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // overall progress card
                  Container(
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),

                      color: Color(0xFF8BE3D0),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            // icon circle
                            Container(
                              width: 62,
                              height: 62,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),

                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // text section
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Overall Progress",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  SizedBox(height: 4),

                                  Text(
                                    "All sports combined",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            // completed exercises count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    getOverallCompleted().toString(),
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "Total Exercises",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // average percentage
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "${getAverageCompletion().toStringAsFixed(0)}%",
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  const Text(
                                    "Average Completion",
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // section title
                  Text(
                    "By Sport",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colortxt,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // empty state
                  if (progressData.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 50),

                      child: Center(
                        child: Text(
                          "No progress available",
                          style: TextStyle(fontSize: 18, color: colortxt),
                        ),
                      ),
                    )
                  // list of progress cards
                  else
                    ...progressData.map(
                      (item) => ProgressCard(
                        item: item,

                        icon: getSportIcon(item['sportName']),
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
