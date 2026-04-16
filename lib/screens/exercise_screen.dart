import 'dart:async';

import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

import '../database/database_service.dart';
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

  // load data on start
  @override
  void initState() {
    super.initState();
    loadExercises(); // fetch exercises
  }

  // clean timer and controllers
  @override
  void dispose() {
    timer?.cancel();
    remainingSeconds.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // get current exercise image path
  String getExerciseImage() {
    String sportFolder = widget.sportName.toLowerCase();

    // indoor or outdoor from DB
    String typeFolder = exercises[currentIndex]["type"];

    String exerciseFileName = exercises[currentIndex]["name"]
        .toLowerCase()
        .replaceAll(" ", "_");

    return "assets/images/exercises/$sportFolder/$typeFolder/$exerciseFileName.png";
  }

  // load exercises by sport and weather
  Future<void> loadExercises() async {
    List<Map<String, dynamic>> allExercises =
        await DatabaseSevice.getExercisesBySport(widget.sportId);

    // filter by weather type
    exercises = allExercises
        .where((exercise) => exercise["type"] == widget.weatherType)
        .toList();

    // set first timer value
    if (exercises.isNotEmpty) {
      remainingSeconds.value = exercises[0]["duration"];
    }

    if (!mounted) return; // stop if screen closed

    setState(() {
      isLoading = false; // loading finished
    });
  }

  // save completed exercise
  Future<void> completeCurrentExercise() async {
    if (exercises.isEmpty) return; // stop if no exercise

    int exerciseId = exercises[currentIndex]["id"];

    bool alreadyCompleted = await DatabaseSevice.isExerciseAlreadyCompleted(
      widget.userId,
      widget.sportId,
      exerciseId,
    );

    String date = DateTime.now().toString(); // current date time

    // always add history
    await DatabaseSevice.addHistory(
      widget.userId,
      widget.sportId,
      exerciseId,
      date,
    );

    // save progress only once
    if (!alreadyCompleted) {
      await DatabaseSevice.markExerciseCompleted(
        widget.userId,
        widget.sportId,
        exerciseId,
      );
    }

    if (!mounted) return; // stop if screen closed

    setState(() {
      completedExercisesCount++; // count completed in this session
    });
  }

  // show finish blocked message
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

  // show first exercise message
  void showFirstExerciseMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("This is the first exercise"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // start timer
  void startTimer() {
    // stop if time finished or already done
    if (remainingSeconds.value <= 0 || currentExerciseCompleted) return;

    timer?.cancel(); // stop old timer

    setState(() {
      isRunning = true; // button state update
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (remainingSeconds.value > 0) {
        // decrease timer
        remainingSeconds.value--;
      } else {
        t.cancel(); // stop timer at zero

        await completeCurrentExercise(); // save completion

        if (!mounted) return; // stop if screen closed

        setState(() {
          isRunning = false; // timer stopped
          currentExerciseCompleted = true; // current exercise done
        });

        // show completed message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${exercises[currentIndex]['name']} completed"),
          ),
        );
      }
    });
  }

  // pause timer
  void pauseTimer() {
    timer?.cancel(); // stop timer

    setState(() {
      isRunning = false; // update state
    });
  }

  // reset timer state
  void resetTimer() {
    timer?.cancel(); // stop timer

    if (exercises.isEmpty) return; // stop if no exercise

    setState(() {
      remainingSeconds.value =
          exercises[currentIndex]["duration"]; // reset time
      isRunning = false; // timer not running
      currentExerciseCompleted = false; // allow current exercise again
    });
  }

  // go to next exercise or finish
  Future<void> goToNextExercise() async {
    timer?.cancel(); // stop timer before moving

    if (currentIndex < exercises.length - 1) {
      // move to next page
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      // last exercise reached
      if (completedExercisesCount <= 0) {
        showFinishBlockedMessage(); // block finish if none completed
        return;
      }

      int completedCount = await DatabaseSevice.getCompletedExercisesCount(
        widget.userId,
        widget.sportId,
      ); // get progress count

      if (!mounted) return; // stop if screen closed

      // go to completed screen
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

  // go to previous exercise
  Future<void> goToPreviousExercise() async {
    timer?.cancel(); // stop timer before moving

    if (currentIndex > 0) {
      // move to previous page
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      showFirstExerciseMessage(); // already at first exercise
    }
  }

  // skip current exercise
  Future<void> skipExercise() async {
    timer?.cancel(); // stop timer before skip

    if (currentIndex < exercises.length - 1) {
      // skip to next page
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      // last exercise reached
      if (completedExercisesCount <= 0) {
        showFinishBlockedMessage(); // block if nothing completed
      } else {
        await goToNextExercise(); // finish workout
      }
    }
  }

  // update page state on swipe
  void onExerciseChanged(int index) {
    timer?.cancel(); // stop old timer

    setState(() {
      currentIndex = index; // update current page
      remainingSeconds.value = exercises[currentIndex]["duration"]; // new time
      isRunning = false; // timer off
      currentExerciseCompleted = false; // new exercise not done yet
    });
  }

  // format timer text
  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    String minText = minutes.toString().padLeft(2, '0');
    String secText = seconds.toString().padLeft(2, '0');

    return "$minText:$secText"; // mm:ss
  }

  // get page progress
  double getProgressValue() {
    if (exercises.isEmpty) return 0; // avoid divide error
    return (currentIndex + 1) / exercises.length; // progress percent
  }

  // build page dots
  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(exercises.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 18 : 8, // active dot wider
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFFD4F24C) // active dot color
                : Colors.grey, // inactive dot color
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
            body: Center(child: CircularProgressIndicator()), // loading spinner
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
            appBar: AppBar(title: Text(widget.sportName)), // top bar
            body: Center(
              child: Text(
                "No ${widget.weatherType} exercises found",
                style: TextStyle(color: colortxt),
              ), // empty message
            ),
          );
        },
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        // check if current page is last
        final bool isLastExercise = currentIndex == exercises.length - 1;

        return Scaffold(
          backgroundColor: colorbg,
          appBar: AppBar(
            backgroundColor: const Color(0xFF61D4C0),
            foregroundColor: Colors.white,
            title: Text(widget.sportName), // app bar title
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // style label
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

                  // progress text row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // current step text
                      Text(
                        "Exercise ${currentIndex + 1} of ${exercises.length}",
                        style: TextStyle(fontSize: 16, color: colortxt),
                      ),
                      // progress percent
                      Text(
                        "${(getProgressValue() * 100).toStringAsFixed(0)}%",
                        style: TextStyle(fontSize: 16, color: colortxt),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // top progress bar
                  LinearProgressIndicator(
                    value: getProgressValue(),
                    color: const Color(0xFF61D4C0),
                    backgroundColor: const Color(0xFFD9F3EC),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  const SizedBox(height: 20),

                  // exercise pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: onExerciseChanged, // update page state
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // exercise image box
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFE8F7F3),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  getExerciseImage(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(exercise["name"]),
                                    ); // fallback text
                                  },
                                ),
                              ),

                              const SizedBox(height: 22),

                              // exercise name
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

                              // exercise description
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

                              // live timer circle
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
                                      ), // live changing timer
                                    );
                                  },
                                )
                              // fixed timer circle
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
                                  ), // static timer for other pages
                                ),

                              const SizedBox(height: 28),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // start and pause button
                  ElevatedButton.icon(
                    onPressed: currentExerciseCompleted
                        ? null // disable if current done
                        : (isRunning
                              ? pauseTimer
                              : startTimer), // toggle action
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

                  // bottom action buttons
                  Row(
                    children: [
                      // back button
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

                      // skip button
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

                      // next or finish button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLastExercise
                                ? (completedExercisesCount > 0
                                      ? const Color(0xFF61D4C0) // enable finish
                                      : Colors.grey) // disable finish
                                : (currentExerciseCompleted
                                      ? const Color(0xFF61D4C0) // enable next
                                      : Colors.grey), // disable next
                            foregroundColor: colortxt,
                          ),
                          onPressed: isLastExercise
                              ? () {
                                  if (completedExercisesCount <= 0) {
                                    showFinishBlockedMessage(); // block finish
                                    return;
                                  }
                                  goToNextExercise(); // finish workout
                                }
                              : (currentExerciseCompleted
                                    ? goToNextExercise // allow next
                                    : null), // block next
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

                  // bottom dots
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
