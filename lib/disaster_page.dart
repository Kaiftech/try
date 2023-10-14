import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterPage extends StatefulWidget {
  const DisasterPage({super.key});

  @override
  DisasterPageState createState() => DisasterPageState();
}

class DisasterPageState extends State<DisasterPage> {
  List<dynamic> disasterData = [];

  Future<List<dynamic>> fetchDisasterData() async {
    const apiKey = '2aH5raFsA6kEoCGI0EK9AAyQAeHgWl3di8RyHVcI';
    final apiUrl = Uri.parse(
        'https://eonet.gsfc.nasa.gov/api/v2.1/events?api_key=$apiKey');
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final events = data['events'];
      return events;
    } else {
      throw Exception('Failed to load disaster data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDisasterData().then((data) {
      setState(() {
        disasterData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Disasters'),
      ),
      body: ListView.builder(
        itemCount: disasterData.length,
        itemBuilder: (context, index) {
          final event = disasterData[index];
          final title = event['title'];
          final description = event['description'];
          final location = event['geometries'][0]['coordinates'];
          final date = event['geometries'][0]['date'];

          return ListTile(
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: $description'),
                Text(
                    'Location: Latitude ${location[1]}, Longitude ${location[0]}'),
                Text('Date: $date'),
              ],
            ),
          );
        },
      ),
    );
  }
}
