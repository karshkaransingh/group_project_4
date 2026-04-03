import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "1232c44c5ae6dfca21000804cd673892";

  static Future<Map<String, dynamic>> getWeatherData(String city) async {
    try {
      final url =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return {"success": false};
      }

      final data = jsonDecode(response.body);

      final mainWeather = data["weather"][0]["main"].toString();
      final icon = data["weather"][0]["icon"].toString();
      final temperature = (data["main"]["temp"] as num).toDouble();
      final cityName = data["name"].toString();

      final badWeather =
          mainWeather == "Rain" ||
          mainWeather == "Snow" ||
          mainWeather == "Thunderstorm" ||
          mainWeather == "Clouds";

      return {
        "success": true,
        "city": cityName,
        "temperature": temperature,
        "mainWeather": mainWeather,
        "icon": icon,
        "workoutType": badWeather ? "indoor" : "outdoor",
        "styleName": badWeather ? "Home Style" : "Athletic Style",
        "message": badWeather
            ? "Weather is not good for outdoor training!"
            : "Perfect weather for outdoor training!",
      };
    } catch (e) {
      return {"success": false};
    }
  }
}
