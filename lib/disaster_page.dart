import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterPage extends StatefulWidget {
  const DisasterPage({super.key});

  @override
  DisasterPageState createState() => DisasterPageState();
}

class DisasterPageState extends State<DisasterPage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Disasters'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDisasterData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator with a rotating animation
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Handle errors
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Handle the case when no data is available
            return const Center(child: Text('No disaster data available.'));
          } else {
            // Display the data
            final disasterData = snapshot.data;
            return ListView.builder(
              itemCount: disasterData!.length,
              itemBuilder: (context, index) {
                final event = disasterData[index];
                final title = event['title'];
                return ListTile(
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location: ${event['categories'][0]['title']}'),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
