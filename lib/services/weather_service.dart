import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherService {
  static String apiKey = "1232c44c5ae6dfca21000804cd673892";

  static Future<String> getWeatherType(String city) async {
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey";

    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      String mainWeather = data['weather'][0]['main'];

      if (mainWeather == "Rain" ||
          mainWeather == "Thunderstorm" ||
          mainWeather == "Snow") {
        return "indoor";
      } else {
        return "outdoor";
      }
    } else {
      return "indoor";
    }
  }
}
