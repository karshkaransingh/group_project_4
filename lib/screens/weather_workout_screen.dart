import 'package:flutter/material.dart';

import '../services/weather_service.dart';
import 'exercise_screen.dart';

class WeatherWorkoutScreen extends StatefulWidget {
  final int userId;
  final int sportId;
  final String sportName;

  const WeatherWorkoutScreen({
    super.key,
    required this.userId,
    required this.sportId,
    required this.sportName,
  });

  @override
  State<WeatherWorkoutScreen> createState() => _WeatherWorkoutScreenState();
}

class _WeatherWorkoutScreenState extends State<WeatherWorkoutScreen> {
  bool isLoading = true;
  String errorMessage = "";
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    final data = await WeatherService.getWeatherData("Winnipeg");

    if (!mounted) return;

    setState(() {
      if (data["success"] == true) {
        weatherData = data;
        errorMessage = "";
      } else {
        weatherData = null;
        errorMessage = "Could not load weather.";
      }
      isLoading = false;
    });
  }

  String getWeatherBackground() {
    if (weatherData == null) {
      return "https://images.unsplash.com/photo-1500375592092-40eb2168fd21";
    }

    String weather = weatherData!["mainWeather"].toString().toLowerCase();

    switch (weather) {
      case "rain":
      case "drizzle":
        return "https://images.unsplash.com/photo-1515694346937-94d85e41e6f0";

      case "snow":
        return "https://images.unsplash.com/photo-1483664852095-d6cc6870702d";

      case "clouds":
        return "https://images.unsplash.com/photo-1534088568595-a066f410bcda";

      case "fog":
      case "mist":
      case "haze":
      case "smoke":
        return "https://images.unsplash.com/photo-1487621167305-5d248087c724";

      case "clear":
        return "https://images.unsplash.com/photo-1472145246862-b24cf25c4a36";

      case "thunderstorm":
        return "https://images.unsplash.com/photo-1500674425229-f692875b0ab7";

      default:
        return "https://images.unsplash.com/photo-1500375592092-40eb2168fd21";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty || weatherData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(errorMessage),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = "";
                });
                loadWeather();
              },
              child: const Text("Try Again"),
            ),
          ],
        ),
      );
    }

    final name = weatherData!["mainWeather"]?.toString() ?? "weather";
    final city = weatherData!["city"]?.toString() ?? "Waterloo";
    final icon = weatherData!["icon"]?.toString() ?? "01d";
    final styleName = weatherData!["styleName"]?.toString() ?? "Athletic Style";
    final workoutType = weatherData!["workoutType"]?.toString() ?? "outdoor";
    final message =
        weatherData!["message"]?.toString() ??
        "Perfect weather for outdoor training! The conditions are ideal for maximum performance.";
    final temperature =
        (weatherData!["temperature"] as num?)?.toDouble() ?? 0.0;

    return Container(
      color: const Color(0xFFE9E9E9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 26),
        child: Column(
          children: [
            Text(
              "${widget.sportName} Training!",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
                decoration: TextDecoration.none,
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(getWeatherBackground()),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withOpacity(0.18),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${temperature.toStringAsFixed(0)}°C",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const Spacer(),
                          Image.network(
                            "https://openweathermap.org/img/wn/$icon@4x.png",
                            width: 110,
                            height: 110,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.wb_cloudy,
                                size: 72,
                                color: Colors.black,
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF86D8C4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                styleName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E3A37),
                  decoration: TextDecoration.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E12F),
                borderRadius: BorderRadius.circular(38),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1B1F),
                      borderRadius: BorderRadius.circular(34),
                    ),
                    child: Column(
                      children: [
                        Text(
                          workoutType == "indoor"
                              ? "Indoor Workout"
                              : "Outdoor Workout",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          workoutType == "indoor"
                              ? "Weather is not good for outdoor training! Indoor exercises are better for today."
                              : "Perfect weather for outdoor training! The conditions are ideal for maximum performance.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.45,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58C0A8),
                        foregroundColor: const Color(0xFF2D4A45),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExerciseScreen(
                              userId: widget.userId,
                              sportId: widget.sportId,
                              sportName: widget.sportName,
                              weatherType: workoutType,
                              styleName: styleName,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Start Workout",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFFC6C23F),
                        side: const BorderSide(
                          color: Color(0xFF7A7730),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Choose Different Sport",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
