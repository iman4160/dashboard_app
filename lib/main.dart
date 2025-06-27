// main.dart
import 'package:flutter/material.dart';
import 'package:dashboard/sign_in_page.dart'; // Make sure this path is correct based on your project name

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign In App',
      debugShowCheckedModeBanner: false, // <--- ADD THIS LINE
      theme: ThemeData(
        // Define the primary color from the user's request
        primaryColor: const Color(0xFF1b9349), // Green
        // Define the accent color from the user's request
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(
            0xFF1b9349, // Green
            <int, Color>{
              50: const Color(0xFFE2F0E7),
              100: const Color(0xFFB3DBBF),
              200: const Color(0xFF80C696),
              300: const Color(0xFF4DAF6C),
              400: const Color(0xFF2C9C4D),
              500: const Color(0xFF1b9349), // Primary Green
              600: const Color(0xFF188741),
              700: const Color(0xFF137A38),
              800: const Color(0xFF0E6E30),
              900: const Color(0xFF095A21),
            },
          ),
        ).copyWith(
          secondary: const Color(0xFF3753a2), // Blue
        ),
        // Set up input decoration theme globally for consistent styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners for text fields
            borderSide: BorderSide.none, // No border for filled fields
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFF1b9349), width: 2.0), // Green focus border
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
        // Set up button theme globally
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1b9349), // Green button background
            foregroundColor: Colors.white, // White text color
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0), // Rounded corners for button
            ),
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF3753a2), // Blue for text links
            textStyle: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Set global font family to Inter if available on the system, otherwise default
        fontFamily: 'Inter',
      ),
      home: const SignInPage(), // Set SignInPage as the initial page
    );
  }
}
