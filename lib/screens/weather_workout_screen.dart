import 'package:flutter/material.dart';
import 'package:group_project_4/main.dart';

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

  String selectedCity = "Waterloo";

  final List<String> cities = [
    "Waterloo",
    "Toronto",
    "London",
    "Brampton",
    "Mississauga",
    "Puranpur",
    "Dubai",
  ];

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final data = await WeatherService.getWeatherData(selectedCity);

    if (!mounted) return;

    setState(() {
      if (data["success"] == true) {
        weatherData = data;
      } else {
        weatherData = null;
        errorMessage = "Unable to load weather data.";
      }
      isLoading = false;
    });
  }

  String getWeatherBackground() {
    if (weatherData == null) {
      return "assets/images/weather/null.png";
    }

    final weather = weatherData!["mainWeather"].toString().toLowerCase();

    switch (weather) {
      case "rain":
      case "drizzle":
        return "assets/images/weather/rain.png";
      case "snow":
        return "assets/images/weather/snow.png";
      case "clouds":
        return "assets/images/weather/clouds.png";
      case "fog":
      case "mist":
      case "haze":
      case "smoke":
        return "assets/images/weather/fog.png";
      case "clear":
        return "assets/images/weather/clear.png";
      case "thunderstorm":
        return "assets/images/weather/thunderstorm.png";
      default:
        return "assets/images/weather/null.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String weatherName = weatherData?["mainWeather"]?.toString() ?? "";
    final String city = weatherData?["city"]?.toString() ?? selectedCity;
    final String icon = weatherData?["icon"]?.toString() ?? "";
    final String styleName =
        weatherData?["styleName"]?.toString() ?? "Indoor Training";
    final String workoutType =
        weatherData?["workoutType"]?.toString() ?? "indoor";
    final String message =
        weatherData?["message"]?.toString() ??
        "Indoor exercises are recommended for now.";
    final double temperature = ((weatherData?["temperature"] ?? 0) as num)
        .toDouble();

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return Scaffold(
          backgroundColor: colorbg,
          appBar: AppBar(
            backgroundColor: colorbg,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: colortxt),
            title: Text(
              "${widget.sportName} Training",
              style: TextStyle(color: colortxt, fontWeight: FontWeight.bold),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: AssetImage(getWeatherBackground()),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.black.withOpacity(0.20),
                          ),
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                          child: weatherData == null
                              ? Center(
                                  child: Text(
                                    errorMessage.isEmpty
                                        ? "Unable to load weather."
                                        : errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          city,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${temperature.toStringAsFixed(0)}°C",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 56,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (icon.isNotEmpty)
                                          Image.network(
                                            "https://openweathermap.org/img/wn/$icon@4x.png",
                                            width: 110,
                                            height: 110,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.wb_cloudy,
                                                    size: 72,
                                                    color: Colors.white,
                                                  );
                                                },
                                          )
                                        else
                                          const Icon(
                                            Icons.wb_cloudy,
                                            size: 72,
                                            color: Colors.white,
                                          ),
                                      ],
                                    ),
                                    Text(
                                      weatherName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: const Color(0xFF8BE3D0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            styleName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: const Color(0xFF8BE3D0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                28,
                                20,
                                26,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF61D4C0),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    workoutType == "indoor"
                                        ? "Indoor Workout"
                                        : "Outdoor Workout",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF61D4C0),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: weatherData == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ExerciseScreen(
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.grey,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Choose Different Sport",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF61D4C0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedCity,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF61D4C0),
                                  iconEnabledColor: Colors.white,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: cities.map((cityItem) {
                                    return DropdownMenuItem<String>(
                                      value: cityItem,
                                      child: Text(cityItem),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    if (value == null) return;

                                    setState(() {
                                      selectedCity = value;
                                    });

                                    await loadWeather();
                                  },
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
      },
    );
  }
}
