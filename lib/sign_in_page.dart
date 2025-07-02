// sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:dashboard/home_page.dart';
import 'package:local_auth/local_auth.dart'; // NEW: Import local_auth

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignInButtonEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication(); // NEW: LocalAuthentication instance
  bool _canCheckBiometrics = false; // NEW: To store biometric availability status

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _checkBiometrics(); // NEW: Check biometric availability on init
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateFields);
    _passwordController.removeListener(_validateFields);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateFields() {
    setState(() {
      _isSignInButtonEnabled =
          _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  void _handleSignIn() {
    if (_isSignInButtonEnabled) {
      print('Signing in with:');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _handleCreateAccount() {
    print('Navigating to create account page...');
  }

  // NEW: Check if biometrics are available and enrolled
  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } catch (e) {
      print("Error checking biometrics: $e");
    }

    // Check if any biometrics are enrolled (e.g., fingerprint, face)
    bool hasEnrolledBiometrics = false;
    if (canCheckBiometrics) {
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isNotEmpty) {
        hasEnrolledBiometrics = true;
      }
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics && hasEnrolledBiometrics;
    });
  }

  // NEW: Authenticate user using biometrics
  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint to log in', // Message shown to user
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep authentication session active
          biometricOnly: true, // Only allow biometric authentication
        ),
      );
    } catch (e) {
      print("Error during biometric authentication: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biometric authentication failed: ${e.toString()}')),
      );
    }

    if (authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication successful!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Icon(
                    Icons.lock,
                    size: 100.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 32.0),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20.0),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (_isSignInButtonEnabled) {
                      _handleSignIn();
                    }
                  },
                ),
                const SizedBox(height: 30.0),

                ElevatedButton(
                  onPressed: _isSignInButtonEnabled ? _handleSignIn : null,
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 20.0),

                // NEW: Biometric Login Button
                if (_canCheckBiometrics) // Only show button if biometrics are available
                  Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton.icon(
                        onPressed: _authenticateWithBiometrics,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Login with Biometrics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary, // Use accent blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20.0),

                TextButton(
                  onPressed: _handleCreateAccount,
                  child: const Text(
                    "Don't have an account? Create one",
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
