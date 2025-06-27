// home_page.dart
import 'package:flutter/material.dart';
import 'package:dashboard/profile_page.dart'; // Corrected import
import 'package:dashboard/customers_screen.dart'; // Corrected import
import 'package:dashboard/device_io_page.dart'; // Corrected import

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the colors based on the theme from main.dart
    final Color primaryGreen = Theme.of(context).primaryColor;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    // Get screen dimensions for responsiveness
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 600; // Define a breakpoint for small screens

    // Adjust padding and font sizes based on screen size
    final double horizontalPadding = isSmallScreen ? 16.0 : 32.0;
    final double verticalPadding = isSmallScreen ? 16.0 : 32.0;
    final double gridSpacing = isSmallScreen ? 16.0 : 24.0;
    final double iconSize = isSmallScreen ? 36.0 : 48.0;
    final double contentFontSize = isSmallScreen ? 14.0 : 18.0;
    final double valueFontSize = isSmallScreen ? 20.0 : 28.0;
    final double buttonFontSize = isSmallScreen ? 16.0 : 20.0;
    final double appBarTitleFontSize = isSmallScreen ? 20.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Softnet Technologies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: appBarTitleFontSize, // Responsive font size for app bar title
          ),
        ),
        backgroundColor: primaryGreen, // Use the green primary color
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Grid of information squares
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // 2 columns in the grid
                  crossAxisSpacing: gridSpacing, // Responsive horizontal space
                  mainAxisSpacing: gridSpacing, // Responsive vertical space
                  children: <Widget>[
                    // Top-left: Green square - Total Verification
                    _buildGridSquare(
                      context,
                      color: primaryGreen,
                      content: 'Total Verification',
                      value: '1,234', // Example value
                      icon: Icons.check_circle_outline,
                      iconSize: iconSize,
                      contentFontSize: contentFontSize,
                      valueFontSize: valueFontSize,
                    ),
                    // Top-right: Blue square - New Customers Onboarded
                    _buildGridSquare(
                      context,
                      color: accentBlue,
                      content: 'New Customers Onboarded',
                      value: '567', // Example value
                      icon: Icons.person_add_alt_1,
                      iconSize: iconSize,
                      contentFontSize: contentFontSize,
                      valueFontSize: valueFontSize,
                    ),
                    // Bottom-left: Blue square - Pending Verification
                    _buildGridSquare(
                      context,
                      color: accentBlue,
                      content: 'Pending Verification',
                      value: '89', // Example value
                      icon: Icons.pending_actions,
                      iconSize: iconSize,
                      contentFontSize: contentFontSize,
                      valueFontSize: valueFontSize,
                    ),
                    // Bottom-right: Green square - Avg Processing Time
                    _buildGridSquare(
                      context,
                      color: primaryGreen,
                      content: 'Avg Processing Time',
                      value: '2.5 hrs', // Example value
                      icon: Icons.access_time,
                      iconSize: iconSize,
                      contentFontSize: contentFontSize,
                      valueFontSize: valueFontSize,
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? 20.0 : 40.0), // Responsive spacing before the button

              // Manage Customers Button
              ElevatedButton(
                onPressed: () {
                  print('Navigating to Manage Customers page...');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CustomersScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue, // Blue button background
                  foregroundColor: Colors.white, // White text
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14.0 : 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Manage Customers',
                  style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: isSmallScreen ? 15.0 : 25.0), // Spacing before Device IO button

              // Device I/O Button - THIS IS THE NEW BUTTON
              ElevatedButton(
                onPressed: () {
                  print('Navigating to Device I/O Page...');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DeviceIOPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, // Green
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14.0 : 18.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Device I/O',
                  style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: isSmallScreen ? 15.0 : 25.0), // Responsive spacing before the view profile button
            ],
          ),
        ),
      ),
      // Bottom navigation/button for View Profile
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
        child: ElevatedButton(
          onPressed: () {
            print('Navigating to View Profile page...');
            // Navigate to the ProfilePage
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen, // Green button background
            foregroundColor: Colors.white, // White text
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14.0 : 18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(
            'View Profile',
            style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Helper method to build each grid square
  Widget _buildGridSquare(
      BuildContext context, {
        required Color color,
        required String content,
        required String value,
        required IconData icon,
        required double iconSize,
        required double contentFontSize,
        required double valueFontSize,
      }) {
    return Card(
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: iconSize, // Responsive icon size
              color: Colors.white,
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: contentFontSize, // Responsive content font size
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: valueFontSize, // Responsive value font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
