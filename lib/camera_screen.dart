// camera_screen.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

// Global variable to store available cameras
List<CameraDescription> cameras = [];

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final GetStorage _box = GetStorage();
  List<String> _capturedImagePaths = []; // Store paths of captured images

  @override
  void initState() {
    super.initState();
    _loadCapturedImages(); // Load previously captured images
    _initializeCamera(); // Initialize camera on screen load
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    var status = await Permission.camera.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied. Please enable it in settings.')),
      );
      return;
    }

    if (cameras.isEmpty) {
      // Ensure cameras are initialized once globally or passed
      try {
        cameras = await availableCameras();
      } on CameraException catch (e) {
        print('Error: ${e.code}\nError Message: ${e.description}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing cameras: ${e.description}')),
        );
      }
    }

    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0], // Use the first available camera
        ResolutionPreset.medium, // Set camera resolution
        enableAudio: false, // No audio needed for image capture
      );

      _initializeControllerFuture = _controller?.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {}); // Rebuild to show camera preview
      }).catchError((error) {
        if (error is CameraException) {
          switch (error.code) {
            case 'CameraAccessDenied':
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Camera access denied.')),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Camera error: ${error.description}')),
              );
              break;
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cameras found on this device.')),
      );
    }
  }

  // Load image paths from GetStorage
  void _loadCapturedImages() {
    final List<dynamic>? storedPaths = _box.read('captured_images');
    if (storedPaths != null) {
      setState(() {
        _capturedImagePaths = List<String>.from(storedPaths);
      });
    }
  }

  // Save image paths to GetStorage
  void _saveCapturedImages() {
    _box.write('captured_images', _capturedImagePaths);
  }

  // Capture image
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not initialized. Please wait.')),
      );
      return;
    }

    try {
      final image = await _controller!.takePicture();
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final filePath = '${appDir.path}/$fileName.png';

      // Save the image to the new path
      await File(image.path).copy(filePath);

      setState(() {
        _capturedImagePaths.add(filePath); // Add new image path
      });
      _saveCapturedImages(); // Save updated list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image captured and saved!')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose camera controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Camera',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2, // Take more space for camera preview
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_controller != null && _controller!.value.isInitialized) {
                    return CameraPreview(_controller!);
                  } else {
                    return Center(
                      child: Text(
                        'Failed to load camera preview. Ensure permissions are granted.',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Capture Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Captured Images:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3, // Take more space for the image grid
            child: _capturedImagePaths.isEmpty
                ? Center(
              child: Text(
                'No images captured yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 images per row
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.0, // Square containers
              ),
              itemCount: _capturedImagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryGreen, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0), // Smaller radius for image inside border
                    child: Image.file(
                      File(_capturedImagePaths[index]),
                      fit: BoxFit.cover, // Ensure image fits within container
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.broken_image, color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
