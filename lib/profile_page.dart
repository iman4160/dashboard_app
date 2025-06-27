// profile_page.dart
import 'package:flutter/material.dart';
import 'package:dashboard/sign_in_page.dart'; // Make sure this path is correct for your project

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors from the theme, ensuring consistency
    final Color primaryGreen = Theme.of(context).primaryColor;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    // Get screen dimensions for responsiveness
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600; // Define a breakpoint for small screens

    // Adjust padding and font sizes based on screen size
    final double horizontalPadding = isSmallScreen ? 20.0 : 40.0;
    final double verticalPadding = isSmallScreen ? 20.0 : 40.0;
    final double profileImageSize = isSmallScreen ? 100.0 : 150.0;
    final double nameFontSize = isSmallScreen ? 22.0 : 28.0;
    final double detailFontSize = isSmallScreen ? 16.0 : 18.0;
    final double buttonFontSize = isSmallScreen ? 16.0 : 20.0;
    final double subheadingFontSize = isSmallScreen ? 18.0 : 22.0; // New: Subheading font size

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen, // Green AppBar
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center items horizontally
            children: <Widget>[
              // Circular Profile Picture
              Center(
                child: Container(
                  width: profileImageSize,
                  height: profileImageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300], // Placeholder background color
                    border: Border.all(
                      color: primaryGreen, // Green border
                      width: 4.0,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://placehold.co/150x150/CCCCCC/FFFFFF?text=PROFILE', // Placeholder image
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 30.0), // Spacing below profile picture

              // Customer Name
              Text(
                'John Doe', // Placeholder Name
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen, // Green for emphasis
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 30.0), // Spacing after name

              // User Information Subheading
              Align(
                alignment: Alignment.centerLeft, // Align subheading to the left
                child: Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: subheadingFontSize,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
              const Divider(height: 20, thickness: 1, color: Colors.grey), // Divider for visual separation
              SizedBox(height: isSmallScreen ? 10.0 : 15.0), // Spacing after subheading

              // User ID
              _buildProfileDetailRow(
                icon: Icons.person_outline,
                label: 'User ID',
                value: 'USR123456', // Placeholder User ID
                detailFontSize: detailFontSize,
                iconColor: accentBlue,
              ),
              SizedBox(height: isSmallScreen ? 10.0 : 15.0), // Spacing

              // Username
              _buildProfileDetailRow(
                icon: Icons.account_circle_outlined,
                label: 'Username',
                value: 'john_doe_99', // Placeholder Username
                detailFontSize: detailFontSize,
                iconColor: accentBlue,
              ),
              SizedBox(height: isSmallScreen ? 10.0 : 15.0), // Spacing

              // Email
              _buildProfileDetailRow(
                icon: Icons.email,
                label: 'Email',
                value: 'john.doe@example.com', // Placeholder Email
                detailFontSize: detailFontSize,
                iconColor: accentBlue,
              ),
              SizedBox(height: isSmallScreen ? 10.0 : 15.0), // Spacing

              // Phone Number
              _buildProfileDetailRow(
                icon: Icons.phone,
                label: 'Phone',
                value: '+1 123 456 7890', // Placeholder Phone Number
                detailFontSize: detailFontSize,
                iconColor: accentBlue,
              ),

              const Spacer(), // Pushes the logout button to the bottom

              // Log Out Button
              ElevatedButton(
                onPressed: () {
                  print('Logging out...');
                  // Navigate back to the sign-in page, removing all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                // Updated style to match 'View Profile' button (primary green)
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen, // Changed to primaryGreen
                  foregroundColor: Colors.white, // White text
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14.0 : 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a row for profile details
  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required double detailFontSize,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        // Use MainAxisAlignment.start to align content from the left for detail rows
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: iconColor, size: detailFontSize + 4), // Responsive icon size
          const SizedBox(width: 10.0),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: detailFontSize,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
