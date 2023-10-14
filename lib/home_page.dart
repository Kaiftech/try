import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:response/disaster_page.dart';
import 'package:response/emergency_services.dart';
import 'auth_service.dart';

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

  const EmergencyServiceButton({
    Key? key,
    required this.text,
    required this.number,
  }) : super(key: key);

  Future<void> _callEmergencyService(
      BuildContext context, String phoneNumber) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);

      final AuthService authService = AuthService();
      final isUserLoggedIn = await authService.isUserLoggedIn();

      if (isUserLoggedIn == true) {
        final CustomUser? user = await authService.getCurrentUser();

        if (user != null) {
          // ignore: unused_local_variable
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // ignore: unused_local_variable
          final message =
              '📋 Copy to Clipboard: Emergency! Name: ${user.displayName}, Phone: ${user.phoneNumber}, Blood Group: ${user.bloodGroup}, Location: ${position.latitude}, ${position.longitude}';

          // You removed the SMS functionality here
        }
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
        backgroundColor: const Color.fromARGB(255, 76, 255, 225),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.phone, size: 32),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
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
            child: Text('Tab 2 Content'),
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
            title: 'Tab 2',
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
