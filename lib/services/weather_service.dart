import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // OpenWeather API key
  static const String apiKey = "1232c44c5ae6dfca21000804cd673892";

  // fetch weather data from API
  static Future<Map<String, dynamic>> getWeatherData(String city) async {
    try {
      // API request URL
      final url =
          "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric";

      // send GET request
      final response = await http.get(Uri.parse(url));

      // check if request failed
      if (response.statusCode != 200) {
        return {"success": false};
      }

      // convert JSON response
      final data = jsonDecode(response.body);

      // extract weather values
      final String mainWeather = data["weather"][0]["main"].toString();

      final String icon = data["weather"][0]["icon"].toString();

      final double temperature = (data["main"]["temp"] as num).toDouble();

      final String cityName = data["name"].toString();

      // determine indoor or outdoor workout
      final bool badWeather =
          mainWeather == "Rain" ||
          mainWeather == "Snow" ||
          mainWeather == "Thunderstorm" ||
          mainWeather == "Clouds";

      // return formatted weather data
      return {
        "success": true,

        "city": cityName,

        "temperature": temperature,

        "mainWeather": mainWeather,

        "icon": icon,

        // workout type based on weather
        "workoutType": badWeather ? "indoor" : "outdoor",

        // style label
        "styleName": badWeather ? "Home Style" : "Athletic Style",

        // recommendation message
        "message": badWeather
            ? "Weather is not good for outdoor training! Indoor exercises are better for today."
            : "Perfect weather for outdoor training! The conditions are ideal for maximum performance.",
      };
    }
    // error handling
    catch (e) {
      return {"success": false};
    }
  }
}
