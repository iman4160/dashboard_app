// gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  List<String> _pickedImagePaths = []; // Store paths of picked images

  @override
  void initState() {
    super.initState();
    _loadPickedImages(); // Load previously picked images
  }

  // Load image paths from GetStorage
  void _loadPickedImages() {
    final List<dynamic>? storedPaths = _box.read('picked_images');
    if (storedPaths != null) {
      setState(() {
        _pickedImagePaths = List<String>.from(storedPaths);
      });
    }
  }

  // Save image paths to GetStorage
  void _savePickedImages() {
    _box.write('picked_images', _pickedImagePaths);
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    // Request storage permission (for Android 13+ it might be Photos permission)
    var status = await Permission.photos.request(); // For Android 13+
    if (!status.isGranted && Platform.isAndroid) {
      // Fallback for older Android versions
      status = await Permission.storage.request();
    }

    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied. Please enable it in settings.')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
        final filePath = '${appDir.path}/$fileName.png';

        // Save the image to the app's local directory
        await File(image.path).copy(filePath);

        setState(() {
          _pickedImagePaths.add(filePath); // Add new image path
        });
        _savePickedImages(); // Save updated list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image picked and saved!')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image from Gallery'),
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
                'Picked Images:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ),
          Expanded(
            child: _pickedImagePaths.isEmpty
                ? Center(
              child: Text(
                'No images picked yet.',
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
              itemCount: _pickedImagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryGreen, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.0), // Smaller radius for image inside border
                    child: Image.file(
                      File(_pickedImagePaths[index]),
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
