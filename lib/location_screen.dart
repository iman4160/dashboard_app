// location_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For location services
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'package:permission_handler/permission_handler.dart'; // For permission handling

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = 'Tap "Get My Location" to fetch data.';
  double? _latitude;
  double? _longitude;
  // String? _continent; // Removed: 'continent' is not available in Placemark
  String? _country;
  String? _city; // Can be city, town, village
  String? _stateProvinceDistrict; // Can be state, province, district

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
  }

  Future<void> _checkLocationPermissionStatus() async {
    // Check current status
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted || status.isPermanentlyDenied) {
      setState(() {
        _locationMessage = 'Location permission is required to get your location. Please grant it.';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Fetching location...';
      _latitude = null;
      _longitude = null;
      // _continent = null; // Removed
      _country = null;
      _city = null;
      _stateProvinceDistrict = null;
    });

    try {
      // Request permission if not granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = 'Location permissions are permanently denied. Please enable them from app settings.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
        return;
      }

      // When permissions are granted, get the current position.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationMessage = 'Location fetched successfully!';
      });

      // Perform reverse geocoding
      await _getAddressFromCoordinates(position.latitude, position.longitude);

    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          // _continent = place.continent; // Removed
          _country = place.country;
          _city = place.locality ?? place.subLocality ?? place.thoroughfare; // Prioritize locality, then sublocality, then thoroughfare
          _stateProvinceDistrict = place.administrativeArea ?? place.subAdministrativeArea; // Prioritize administrativeArea
        });
      } else {
        setState(() {
          _locationMessage = 'Could not find address for these coordinates.';
        });
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      setState(() {
        _locationMessage = 'Error getting address: ${e.toString()}';
      });
    }
  }

  Widget _buildLocationDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.location_on, size: 80, color: primaryGreen.withOpacity(0.7)),
              const SizedBox(height: 20),
              Text(
                _locationMessage,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Get My Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              const SizedBox(height: 30),
              if (_latitude != null && _longitude != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryGreen.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Details:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),
                      _buildLocationDetailRow('Latitude', _latitude?.toStringAsFixed(6)),
                      _buildLocationDetailRow('Longitude', _longitude?.toStringAsFixed(6)),
                      // _buildLocationDetailRow('Continent', _continent), // Removed
                      _buildLocationDetailRow('Country', _country),
                      _buildLocationDetailRow('City/Town', _city),
                      _buildLocationDetailRow('State/Province/District', _stateProvinceDistrict),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              // Note about map picking
              Text(
                'Map-based location picking would require a dedicated map library (e.g., google_maps_flutter) and further implementation.',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
