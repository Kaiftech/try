import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  final String apiKey = 'lhaPLP6aEk7oLMIThrR8YgzMaaB0yYlt';
  final String city = 'Mumbai'; // Replace with your desired city
  final String apiUrl = 'https://api.tomorrow.io/v4/timelines';

  Map<String, dynamic> weatherData = {};

  Future<void> fetchWeatherData() async {
    final uri = Uri.parse(
        '$apiUrl?location=$city&fields=temperature&timesteps=current,1d&apikey=$apiKey');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        weatherData = data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast for $city'),
      ),
      body: Center(
        child: weatherData.isEmpty
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  WeatherCard(
                    title: 'Today',
                    temperature: weatherData['data']['timelines'][0]
                        ['intervals'][0]['values']['temperature'],
                    weatherIcon:
                        Icons.wb_sunny, // Weather icon for sunny conditions
                  ),
                  WeatherCard(
                    title: 'Tomorrow',
                    temperature: weatherData['data']['timelines'][1]
                        ['intervals'][0]['values']['temperature'],
                    weatherIcon:
                        Icons.cloud, // Weather icon for cloudy conditions
                  ),
                ],
              ),
      ),
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String title;
  final double temperature;
  final IconData weatherIcon;

  const WeatherCard(
      {super.key,
      required this.title,
      required this.temperature,
      required this.weatherIcon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24),
            ),
            Icon(
              weatherIcon,
              size: 64,
              color: Colors.blue, // You can customize the color
            ),
            Text(
              'Temperature: ${temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Date: ${DateFormat.yMd().add_jm().format(DateTime.now())}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
