import 'dart:async';

import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/db_helper.dart';
import 'workout_completed_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final int userId;
  final int sportId;
  final String sportName;
  final String weatherType;
  final String styleName;

  const ExerciseScreen({
    super.key,
    required this.userId,
    required this.sportId,
    required this.sportName,
    required this.weatherType,
    required this.styleName,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;

  int currentIndex = 0;

  Timer? timer;
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(0);
  bool isRunning = false;
  bool currentExerciseCompleted = false;
  int completedExercisesCount = 0;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  @override
  void dispose() {
    timer?.cancel();
    remainingSeconds.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadExercises() async {
    List<Map<String, dynamic>> allExercises =
        await DBHelper.getExercisesBySport(widget.sportId);

    exercises = allExercises
        .where((exercise) => exercise["type"] == widget.weatherType)
        .toList();

    if (exercises.isNotEmpty) {
      remainingSeconds.value = exercises[0]["duration"];
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  Future<void> completeCurrentExercise() async {
    if (exercises.isEmpty) return;

    int exerciseId = exercises[currentIndex]["id"];

    bool alreadyCompleted = await DBHelper.isExerciseAlreadyCompleted(
      widget.userId,
      widget.sportId,
      exerciseId,
    );

    if (!alreadyCompleted) {
      String date = DateTime.now().toString();

      await DBHelper.addHistory(
        widget.userId,
        widget.sportId,
        exerciseId,
        date,
      );

      if (!mounted) return;

      setState(() {
        completedExercisesCount++;
      });
    }
  }

  void showFinishBlockedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Complete at least one exercise before finishing workout",
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void showFirstExerciseMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("This is the first exercise"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void startTimer() {
    if (remainingSeconds.value <= 0 || currentExerciseCompleted) return;

    timer?.cancel();

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        t.cancel();

        await completeCurrentExercise();

        if (!mounted) return;

        setState(() {
          isRunning = false;
          currentExerciseCompleted = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${exercises[currentIndex]['name']} completed"),
          ),
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

    if (exercises.isEmpty) return;

    setState(() {
      remainingSeconds.value = exercises[currentIndex]["duration"];
      isRunning = false;
      currentExerciseCompleted = false;
    });
  }

  Future<void> goToNextExercise() async {
    timer?.cancel();

    if (currentIndex < exercises.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      if (completedExercisesCount <= 0) {
        showFinishBlockedMessage();
        return;
      }

      int completedCount = await DBHelper.getCompletedExercisesCount(
        widget.userId,
        widget.sportId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompletedScreen(
            userId: widget.userId,
            sportName: widget.sportName,
            completedExercises: completedCount,
          ),
        ),
      );
    }
  }

  Future<void> goToPreviousExercise() async {
    timer?.cancel();

    if (currentIndex > 0) {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      showFirstExerciseMessage();
    }
  }

  Future<void> skipExercise() async {
    timer?.cancel();

    if (currentIndex < exercises.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      if (completedExercisesCount <= 0) {
        showFinishBlockedMessage();
      } else {
        await goToNextExercise();
      }
    }
  }

  void onExerciseChanged(int index) {
    timer?.cancel();

    setState(() {
      currentIndex = index;
      remainingSeconds.value = exercises[currentIndex]["duration"];
      isRunning = false;
      currentExerciseCompleted = false;
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String minText = minutes.toString().padLeft(2, '0');
    String secText = seconds.toString().padLeft(2, '0');

    return "$minText:$secText";
  }

  double getProgressValue() {
    if (exercises.isEmpty) return 0;
    return (currentIndex + 1) / exercises.length;
  }

  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(exercises.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFFD4F24C)
                : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ValueListenableBuilder<bool>(
        valueListenable: isDarkMode,
        builder: (context, value, child) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    if (exercises.isEmpty) {
      return ValueListenableBuilder<bool>(
        valueListenable: isDarkMode,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: colorbg,
            appBar: AppBar(title: Text(widget.sportName)),
            body: Center(
              child: Text(
                "No ${widget.weatherType} exercises found",
                style: TextStyle(color: colortxt),
              ),
            ),
          );
        },
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        final bool isLastExercise = currentIndex == exercises.length - 1;

        return Scaffold(
          backgroundColor: colorbg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF61D4C0),
            foregroundColor: Colors.white,
            title: Text(widget.sportName),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.styleName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colortxt,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Exercise ${currentIndex + 1} of ${exercises.length}",
                        style: TextStyle(fontSize: 16, color: colortxt),
                      ),
                      Text(
                        "${(getProgressValue() * 100).toStringAsFixed(0)}%",
                        style: TextStyle(fontSize: 16, color: colortxt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: getProgressValue(),
                    color: const Color(0xFF61D4C0),
                    backgroundColor: const Color(0xFFD9F3EC),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: onExerciseChanged,
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 170,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFE8F7F3),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_outline,
                                        size: 70,
                                      ),
                                      const SizedBox(height: 12),
                                      Text("Video: ${exercise["name"]}"),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  exercise["name"],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: colortxt,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  exercise["description"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colortxt,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              if (index == currentIndex)
                                ValueListenableBuilder<int>(
                                  valueListenable: remainingSeconds,
                                  builder: (context, value, child) {
                                    return Container(
                                      width: 150,
                                      height: 150,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFD4F24C),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        formatTime(value),
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD4F24C),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    formatTime(exercise["duration"]),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 28),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: currentExerciseCompleted
                        ? null
                        : (isRunning ? pauseTimer : startTimer),
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      isRunning ? "Pause" : "Start",
                      style: const TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      backgroundColor: const Color(0xFF61D4C0),
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFF61D4C0),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: goToPreviousExercise,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFF61D4C0),
                            side: const BorderSide(color: Color(0xFF61D4C0)),
                          ),
                          onPressed: skipExercise,
                          child: Text(
                            "Skip Exercise",
                            style: TextStyle(color: colortxt, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastExercise
                                ? (completedExercisesCount > 0
                                      ? const Color(0xFF61D4C0)
                                      : Colors.grey)
                                : (currentExerciseCompleted
                                      ? const Color(0xFF61D4C0)
                                      : Colors.grey),
                            foregroundColor: colortxt,
                          ),
                          onPressed: isLastExercise
                              ? () {
                                  if (completedExercisesCount <= 0) {
                                    showFinishBlockedMessage();
                                    return;
                                  }
                                  goToNextExercise();
                                }
                              : (currentExerciseCompleted
                                    ? goToNextExercise
                                    : null),
                          child: Text(
                            isLastExercise ? "Finish" : "Next Exercise",
                            style: TextStyle(
                              color: colortxt,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  buildDots(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
