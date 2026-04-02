import 'dart:async';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'workout_completed_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final int userId;
  final int sportId;
  final String sportName;

  const ExerciseScreen({
    super.key,
    required this.userId,
    required this.sportId,
    required this.sportName,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;

  Timer? timer;
  ValueNotifier<int> remainingSeconds = ValueNotifier<int>(0);
  bool isRunning = false;
  int selectedExerciseId = -1;
  String selectedExerciseName = "";

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  @override
  void dispose() {
    timer?.cancel();
    remainingSeconds.dispose();
    super.dispose();
  }

  Future<void> loadExercises() async {
    exercises = await DBHelper.getExercisesBySport(widget.sportId);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> completeExercise(int exerciseId) async {
    bool alreadyCompleted = await DBHelper.isExerciseAlreadyCompleted(
      widget.userId,
      widget.sportId,
      exerciseId,
    );

    if (alreadyCompleted) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This exercise is already completed")),
      );
      return;
    }

    String date = DateTime.now().toString();

    await DBHelper.addHistory(widget.userId, widget.sportId, exerciseId, date);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Exercise saved in history")));
  }

  void startExerciseTimer(
    int exerciseId,
    String exerciseName,
    int durationInMinutes,
  ) {
    timer?.cancel();

    setState(() {
      selectedExerciseId = exerciseId;
      selectedExerciseName = exerciseName;
      remainingSeconds.value = durationInMinutes * 60;
      isRunning = false;
    });
  }

  void startTimer() {
    if (remainingSeconds.value <= 0) return;

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;

        if (!isRunning && mounted) {
          setState(() {
            isRunning = true;
          });
        }
      } else {
        t.cancel();

        if (!mounted) return;

        setState(() {
          isRunning = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$selectedExerciseName timer completed")),
        );
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();

    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();

    setState(() {
      remainingSeconds.value = 0;
      isRunning = false;
      selectedExerciseId = -1;
      selectedExerciseName = "";
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String minText = minutes.toString().padLeft(2, '0');
    String secText = seconds.toString().padLeft(2, '0');

    return "$minText:$secText";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sportName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
          ? const Center(child: Text("No exercises found"))
          : Column(
              children: [
                if (selectedExerciseId != -1)
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            selectedExerciseName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ValueListenableBuilder<int>(
                            valueListenable: remainingSeconds,
                            builder: (context, value, child) {
                              return Text(
                                formatTime(value),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: startTimer,
                                child: const Text("Start"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: pauseTimer,
                                child: const Text("Pause"),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: resetTimer,
                                child: const Text("Reset"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      var exercise = exercises[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(exercise['name']),
                          subtitle: Text(
                            "${exercise['description']}\nType: ${exercise['type']} | Duration: ${exercise['duration']} min",
                          ),
                          isThreeLine: true,
                          onTap: () {
                            startExerciseTimer(
                              exercise['id'],
                              exercise['name'],
                              exercise['duration'],
                            );
                          },
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await completeExercise(exercise['id']);
                            },
                            child: const Text("Done"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutCompletedScreen(
                            sportName: widget.sportName,
                          ),
                        ),
                      );
                    },
                    child: const Text("Finish Workout"),
                  ),
                ),
              ],
            ),
    );
  }
}
