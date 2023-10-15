import 'package:flutter/material.dart';
import 'package:response/disaster_page.dart';
import 'package:response/login_page.dart';
import 'package:response/weather_page.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(await MyApp.initialize());
  // ignore: unused_local_variable
  TwilioFlutter twilioFlutter = TwilioFlutter(
      accountSid: 'AC1298ffc7af7a572d4c004c2bc6197393',
      authToken: '496efe0e2d698653d5179c873871902c',
      twilioNumber:
          '+12565026068'); // Use a static method to initialize the app
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.isUserSignedIn}) : super(key: key);

  static Future<MyApp> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isUserSignedIn = prefs.getBool('isUserSignedIn') ?? false;

    return MyApp(isUserSignedIn: isUserSignedIn);
  }

  final bool isUserSignedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency response app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: isUserSignedIn ? '/home' : '/registration',
      routes: {
        '/registration': (context) => const RegistrationPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/disaster': (context) => const DisasterPage(),
        '/weather': (context) => const WeatherPage(),
      },
    );
  }
}
