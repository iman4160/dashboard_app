// sign_in_page.dart
import 'package:flutter/material.dart';
// IMPORTANT: Replace 'flutter_app' with your actual project name, e.g., 'dashboard'
// OR if home_page.dart is in the same 'lib' folder, you can use:
// import 'home_page.dart';
import 'package:dashboard/home_page.dart'; // Corrected import path, assuming project is 'dashboard'

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controllers for text fields to get and set their values
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // A boolean state variable to control the enabled/disabled state of the button
  bool _isSignInButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to react to changes in text
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed
    _emailController.removeListener(_validateFields);
    _passwordController.removeListener(_validateFields);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validation method to check if both fields have content
  void _validateFields() {
    setState(() {
      _isSignInButtonEnabled =
          _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  // Function to handle sign-in logic (currently just prints to console)
  void _handleSignIn() {
    // In a real app, you would integrate with authentication services (e.g., Firebase Auth) here
    if (_isSignInButtonEnabled) {
      print('Signing in with:');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      // Navigate to the HomePage upon successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  // Function to handle "Create Account" navigation
  void _handleCreateAccount() {
    print('Navigating to create account page...');
    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a title and the primary color from the theme
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.white, // White text for AppBar title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor, // Use the green primary color
        elevation: 0, // No shadow for a cleaner look
        centerTitle: true,
      ),
      // SafeArea to avoid UI elements being obscured by device notches/status bars
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding around the entire content for better spacing
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              // Align children to the center horizontally
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo or app icon (placeholder)
                Center(
                  child: Icon(
                    Icons.lock, // Example icon
                    size: 100.0,
                    color: Theme.of(context).primaryColor, // Green icon
                  ),
                ),
                const SizedBox(height: 32.0), // Spacing below the icon

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  textInputAction: TextInputAction.next, // Go to next field on "done"
                ),
                const SizedBox(height: 20.0), // Spacing between fields

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Hide password text
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  textInputAction: TextInputAction.done, // "Done" action on keyboard
                  onFieldSubmitted: (_) {
                    if (_isSignInButtonEnabled) {
                      _handleSignIn(); // Call sign-in if button is enabled
                    }
                  },
                ),
                const SizedBox(height: 30.0), // Spacing before the button

                // Sign In Button
                ElevatedButton(
                  onPressed: _isSignInButtonEnabled ? _handleSignIn : null, // Disable if fields are empty
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 20.0), // Spacing after the button

                // "Create Account" Text Link
                TextButton(
                  onPressed: _handleCreateAccount,
                  child: const Text(
                    "Don't have an account? Create one",
                    // Use the accent color defined in MyApp for the link
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
