import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:logger/logger.dart';

final Logger e = Logger();

class SelectProfilePicturePage extends StatefulWidget {
  const SelectProfilePicturePage({super.key});

  @override
  State<SelectProfilePicturePage> createState() =>
      _SelectProfilePicturePageState();
}

class _SelectProfilePicturePageState extends State<SelectProfilePicturePage> {
  late final ImagePicker _picker;
  XFile? _imageFile; // Store the picked image

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker(); // Initialize image picker
  }

  Future<void> _pickImage() async {
    try {
      e.i('Attempting to pick an image from gallery...');

      // Pick image from gallery
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        e.i('Image picked successfully: ${pickedFile.path}');

        setState(() {
          _imageFile = pickedFile; // Store the picked image file
        });
      } else {
        e.w('No image selected. The user canceled the selection.');
      }
    } catch (error) {
      e.e('Error picking image: $error');
    }
  }

  // Show a dialog with the user credentials from the provider and profile pic
  void _showUserDetailsDialog(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context, listen: false);
    final completeName = provider.completeName;
    final birthdate = provider.birthDateFormatted;
    final age = provider.calculatedAge;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the Profile Picture if selected, otherwise show default icon
                _imageFile == null
                    ? const Icon(Icons.account_circle,
                        size: 80, color: Colors.green)
                    : CircleAvatar(
                        radius: 40,
                        backgroundImage: FileImage(File(_imageFile!.path)),
                      ),
                const SizedBox(height: 16),
                Text(
                  'Profile Details',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Complete Name: $completeName'),
                Text('Birthdate: $birthdate'),
                Text('Age: $age'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(); // Close the dialog
                      // Proceed to the next page if necessary
                    },
                    child: const Text('OK',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(), // Add spacing from the top

            // Pick Profile Picture
            GestureDetector(
              onTap: _pickImage, // Trigger image picking
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageFile == null
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : CircleAvatar(
                            radius: 40,
                            backgroundImage: FileImage(File(_imageFile!.path)),
                          ),
                    const SizedBox(width: 10),
                    Text(
                      _imageFile == null
                          ? 'Tap to select profile picture'
                          : 'Tap to change picture',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30), // Add spacing between elements

            // Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _showUserDetailsDialog(context); // Show user details dialog
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const Spacer(), // Add bottom spacing
          ],
        ),
      ),
    );
  }
}
