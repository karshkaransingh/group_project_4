import 'package:flutter/material.dart';

import '../database/db_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (progressData.isEmpty) {
      return const Center(child: Text("No progress available"));
    }

    return RefreshIndicator(
      onRefresh: loadProgress,
      child: ListView.builder(
        itemCount: progressData.length,
        itemBuilder: (context, index) {
          var item = progressData[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['sportName'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Completed: ${item['completed']} / ${item['total']}"),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: item['total'] == 0
                        ? 0
                        : item['completed'] / item['total'],
                  ),
                  const SizedBox(height: 10),
                  Text("${(item['percent'] as double).toStringAsFixed(0)}%"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
