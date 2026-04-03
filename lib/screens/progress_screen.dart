import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'history_screen.dart';

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

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    sports = await DBHelper.getSports();

    progressData = [];

    for (int i = 0; i < sports.length; i++) {
      int sportId = sports[i]['id'];

      int totalExercises = await DBHelper.getTotalExercisesCount(sportId);
      int completedExercises = await DBHelper.getCompletedExercisesCount(
        widget.userId,
        sportId,
      );

      double percent = 0;

      if (totalExercises > 0) {
        percent = (completedExercises / totalExercises) * 100;
      }

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

  int getOverallCompleted() {
    int total = 0;
    for (int i = 0; i < progressData.length; i++) {
      total += progressData[i]['completed'] as int;
    }
    return total;
  }

  int getOverallExercises() {
    int total = 0;
    for (int i = 0; i < progressData.length; i++) {
      total += progressData[i]['total'] as int;
    }
    return total;
  }

  double getAverageCompletion() {
    int overallTotal = getOverallExercises();
    int overallCompleted = getOverallCompleted();

    if (overallTotal == 0) return 0;
    return (overallCompleted / overallTotal) * 100;
  }

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

  Widget buildSportCard(Map<String, dynamic> item) {
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
                child: Icon(
                  getSportIcon(item['sportName']),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['sportName'],
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item['completed']} / ${item['total']} exercises",
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),

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
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: item['total'] == 0 ? 0 : item['completed'] / item['total'],
              backgroundColor: const Color(0xFF29433E),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF61D4C0)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadProgress,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Progress",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Track your journey",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: loadProgress,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF61D4C0), Color(0xFF8BE3D0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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

              SizedBox(
                height: 58,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HistoryScreen(userId: widget.userId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text(
                    "View & Manage Exercise History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),

              const Text(
                "By Sport",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),

              if (progressData.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text(
                      "No progress available",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              else
                ...progressData.map(buildSportCard),
            ],
          ),
        ),
      ),
    );
  }
}
