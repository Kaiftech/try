import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _phoneNumberError;
  String _error = '';
  String _selectedBloodGroup = 'A+'; // Set an initial value

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
      _phoneNumberError = null;
      _error = '';
    });
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text;
    final phoneNumber = _phoneNumberController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        name.isEmpty ||
        _selectedBloodGroup.isEmpty ||
        phoneNumber.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
      });
      return;
    }

    _clearErrors(); // Clear any previous errors

    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    final nameError = _validateName(name);
    final phoneNumberError = _validatePhoneNumber(phoneNumber);

    if (emailError != null ||
        passwordError != null ||
        nameError != null ||
        phoneNumberError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _nameError = nameError;
        _phoneNumberError = phoneNumberError;
      });
      return;
    }

    final User? user = await _authService.registerWithEmailAndPassword(
        email, password, name, _selectedBloodGroup, phoneNumber);

    if (user != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isUserSignedIn', true);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showRegistrationFailedDialog();
    }
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Please enter an email address';
    } else if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? _validatePhoneNumber(String value) {
    if (value.isEmpty) {
      return 'Please enter your phone number';
    } else if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    // You can add more validation for phone numbers here if needed
    return null;
  }

  void _showRegistrationFailedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registration Failed'),
          content: const Text('Please try again.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the home screen for emergencies
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(
              Icons.skip_next, // Change the icon to your preference
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _nameError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedBloodGroup = newValue!;
                    });
                  },
                  items: _bloodGroups.map((bloodGroup) {
                    return DropdownMenuItem<String>(
                      value: bloodGroup,
                      child: Text(bloodGroup),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    errorText: _phoneNumberError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: _emailError,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _passwordError,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                if (_error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _error,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the login page
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
