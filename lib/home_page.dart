import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:geolocator/geolocator.dart';
import 'disaster_page.dart';
import 'emergency_services.dart';
import 'weather_page.dart';
import 'auth_service.dart';
import 'package:twilio_flutter/twilio_flutter.dart'; // Import Twilio package

class EmergencyService {
  const EmergencyService({
    required this.name,
    required this.phoneNumber,
  });

  final String name;
  final String phoneNumber;
}

class EmergencyServiceButton extends StatelessWidget {
  final String text;
  final String number;
  final CustomUser? user;

  const EmergencyServiceButton({
    Key? key,
    required this.text,
    required this.number,
    this.user,
  }) : super(key: key);

  Future<void> _callEmergencyService(
      BuildContext context, String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);

      final AuthService authService = AuthService();
      final isUserLoggedIn = await authService.isUserLoggedIn();

      if (isUserLoggedIn == true && user != null) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final message =
            '📋 Copy to Clipboard: Emergency! Name: ${user?.displayName}, Phone: ${user?.phoneNumber}, Blood Group: ${user?.bloodGroup}, Location: ${position.latitude}, ${position.longitude}';

        // Initialize TwilioFlutter
        TwilioFlutter twilioFlutter = TwilioFlutter(
          accountSid: 'AC1298ffc7af7a572d4c004c2bc6197393',
          authToken: '496efe0e2d698653d5179c873871902c',
          twilioNumber: '+12565026068',
        );

        // Send the message using TwilioFlutter
        await twilioFlutter.sendSMS(
          toNumber: phoneNumber, // Use the same number the user is calling
          messageBody: message, // Use the same message as the body
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not initiate call'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await _callEmergencyService(context, number);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: const Color(0xFF4CFFE1),
        padding: const EdgeInsets.all(12), // Reduce padding to make it smaller
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone, size: 28), // Reduce icon size
          const SizedBox(height: 4), // Reduce spacing between icon and text
          Text(
            text,
            style: const TextStyle(
              fontSize: 16, // Reduce font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const emergencyServices = [
    EmergencyService(name: 'Police', phoneNumber: '100'),
    EmergencyService(name: 'Fire', phoneNumber: '101'),
    EmergencyService(name: 'Ambulance', phoneNumber: '108'),
    EmergencyService(name: 'Women Helpline', phoneNumber: '1091'),
    EmergencyService(name: 'Child Helpline', phoneNumber: '7977227633'),
    EmergencyService(name: 'ERSS (112)', phoneNumber: '112'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Services')),
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              width: 250,
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final service in emergencyServices)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 15,
                      ),
                      child: EmergencyServiceButton(
                        text: service.name,
                        number: service.phoneNumber,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: PersistentTabView(
        context,
        controller: PersistentTabController(),
        screens: [
          Scaffold(
            appBar: AppBar(title: const Text('Emergency Services')),
            body: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.only(top: 90),
                child: Column(
                  children: [
                    for (final service in emergencyServices)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                        child: EmergencyServiceButton(
                          text: service.name,
                          number: service.phoneNumber,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: WeatherPage(),
          ),
          const Center(
            child: DisasterPage(),
          ),
          Center(
            child: EmergencyServicesPage(),
          ),
        ],
        items: [
          PersistentBottomNavBarItem(
            title: 'Contact',
            icon: const Icon(Icons.call_end),
          ),
          PersistentBottomNavBarItem(
            title: 'Weather Forecast',
            icon: const Icon(Icons.business),
          ),
          PersistentBottomNavBarItem(
            title: 'Disaster Page',
            icon: const Icon(Icons.school),
          ),
          PersistentBottomNavBarItem(
            title: 'Emergency Response Guidelines',
            icon: const Icon(Icons.help_center),
          ),
        ],
      ),
    );
  }
}
