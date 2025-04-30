import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:logger/logger.dart';

final Logger e = Logger();

class UserInputConfirmationPage extends StatefulWidget {
  const UserInputConfirmationPage({super.key});

  @override
  State<UserInputConfirmationPage> createState() =>
      _UserInputConfirmationPage();
}

class _UserInputConfirmationPage extends State<UserInputConfirmationPage> {
  late final ImagePicker _picker;
  XFile? _imageFile; // Store the picked image

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker(); // Initialize image picker
  }

  // Function to pick image from camera or gallery
  Future<void> _pickImage() async {
    try {
      // Show a bottom sheet to select image source (Camera or Gallery)
      final pickedSource = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.camera,
                  color: Color.fromARGB(255, 24, 172, 24),
                ),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_album,
                  color: Color.fromARGB(255, 24, 172, 24),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          );
        },
      );

      // If a source is selected, pick image
      if (pickedSource != null) {
        e.i('Attempting to pick an image from $pickedSource...');
        final XFile? pickedFile = await _picker.pickImage(source: pickedSource);

        if (pickedFile != null) {
          e.i('Image picked successfully: ${pickedFile.path}');
          setState(() {
            _imageFile = pickedFile; // Store the picked image file
          });
        } else {
          e.w('No image selected. The user canceled the selection.');
        }
      } else {
        e.w('Image source was not selected.');
      }
    } catch (error) {
      e.e('Error picking image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);

    final completeName = provider.completeName;
    final birthdate = provider.birthDateFormatted;
    final age = provider.calculatedAge;
    final gender =
        provider.selectedGender; // Assuming gender is stored in provider
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Gender icon mapping
    Widget genderIcon;
    switch (gender) {
      case 'Male':
        genderIcon = const Icon(Icons.male, size: 180, color: Colors.white);
        break;
      case 'Female':
        genderIcon = const Icon(Icons.female, size: 180, color: Colors.white);
        break;
      case 'Non-binary':
        genderIcon =
            const Icon(Icons.transgender, size: 180, color: Colors.white);
        break;
      case 'Agender':
        genderIcon =
            const Icon(Icons.accessibility, size: 180, color: Colors.white);
        break;
      case 'Bigender':
        genderIcon =
            const Icon(Icons.accessibility_new, size: 180, color: Colors.white);
        break;
      case 'Cis Man':
        genderIcon = const Icon(Icons.male, size: 180, color: Colors.white);
        break;
      case 'Cis Woman':
        genderIcon = const Icon(Icons.female, size: 180, color: Colors.white);
        break;
      case 'Genderless':
        genderIcon =
            const Icon(Icons.transgender, size: 180, color: Colors.white);
        break;
      case 'Genderqueer':
        genderIcon =
            const Icon(Icons.transgender, size: 180, color: Colors.white);
        break;
      case 'Third Gender':
        genderIcon =
            const Icon(Icons.accessibility_new, size: 180, color: Colors.white);
        break;
      case 'Transgender':
        genderIcon =
            const Icon(Icons.transgender, size: 180, color: Colors.white);
        break;
      case 'Trans Man':
        genderIcon = const Icon(Icons.male, size: 180, color: Colors.white);
        break;
      case 'Trans Woman':
        genderIcon = const Icon(Icons.female, size: 180, color: Colors.white);
        break;
      case 'Two-Spirit':
        genderIcon =
            const Icon(Icons.accessibility, size: 180, color: Colors.white);
        break;
      default:
        genderIcon =
            const Icon(Icons.account_circle, size: 180, color: Colors.white);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Information",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          // Top Container with profile picture and gender icon
          Container(
            color: primaryColor, // Primary color background for the top part
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity, // Half screen height
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Trigger image picking
                    child: _imageFile == null
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, // Primary color border
                                width: 3, // Border thickness
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 90,
                              backgroundColor: primaryColor,
                              child: genderIcon,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white, // Primary color border
                                width: 3, // Border thickness
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 90,
                              backgroundImage:
                                  FileImage(File(_imageFile!.path)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Container with user details and buttons
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.5, // Remaining half of the screen
            width: double.infinity,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: Text(completeName),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.black),
                    title: Text(birthdate),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cake, color: Colors.black),
                    title: Text('Age: $age'),
                  ),
                  const SizedBox(height: 30),

                  // Buttons Section (Back and Continue)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to previous screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Back"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          e.e("Gender selected: ${provider.selectedGender}");
                          // Navigate to next screen or perform necessary action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                        child: const Text("Continue"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
