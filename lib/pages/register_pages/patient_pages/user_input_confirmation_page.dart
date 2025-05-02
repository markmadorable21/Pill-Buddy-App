import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/add_new_caregiver_family_page.dart';
import 'package:pill_buddy/pages/register_pages/patient_pages/create_my_profile_name_page.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:logger/logger.dart';
import 'package:pill_buddy/pages/providers/address_provider.dart';

class UserInputConfirmationPage extends StatefulWidget {
  const UserInputConfirmationPage({super.key});

  @override
  State<UserInputConfirmationPage> createState() =>
      _UserInputConfirmationPage();
}

class _UserInputConfirmationPage extends State<UserInputConfirmationPage> {
  final Logger e = Logger();
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

  void _showAddCaregiverDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible:
          true, // Dialog will not be dismissed by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                // Title Text
                const Text(
                  "Would you like to add a caregiver (family or relative) to help you monitor your medications?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),
                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) =>
                            //           const CreateProfileNamePage()),
                            // );
                          },
                          child: const Text(
                            "Add Existing User",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AddNewCaregiverFamilyPage()),
                            );
                          },
                          child: const Text(
                            "Add New Caregiver/Family",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          // Add Google login action
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const GoogleSIgninPage()),
                          // );
                        },
                        label: Text(
                          "Later",
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicationProvider>(context);
    final provideradd = Provider.of<AddressProvider>(context);
    final address = provideradd.completeAddress;
    final completeName = provider.completeName;
    final birthdate = provider.birthDateFormatted;
    final age = provider.calculatedAge;
    final password = provider.inputtedPassword;
    final email = provider.inputtedEmail;
    final gender =
        provider.selectedGender; // Assuming gender is stored in provider
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Gender icon mapping
    Widget genderIcon;
    switch (gender) {
      case 'Male':
        genderIcon = Icon(Icons.girl, size: 180, color: Colors.grey[200]);
        break;
      case 'Female':
        genderIcon = Icon(Icons.female, size: 180, color: Colors.grey[200]);
        break;

      default:
        genderIcon = Icon(Icons.account_circle,
            size: 180, color: Colors.grey[200]); // Default icon for unknown
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Information",
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Container with profile picture and gender icon
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity, // Half screen height
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickImage, // Trigger image picking
                            child: _imageFile == null
                                ? CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.grey[400],
                                    child: genderIcon,
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            primaryColor, // Primary color border
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
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            child: Text(
                              textAlign: TextAlign.center,
                              "Tap the icon to change your profile picture",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListTile(
                            leading: const Icon(LucideIcons.user,
                                color: Colors.blue),
                            title: Text('Name: $completeName'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.green),
                            title: Text('Birthdate: $birthdate'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.cake, color: Colors.orange),
                            title: Text('Age: $age'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.male, color: Colors.purple),
                            title: Text('Gender: $gender'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.location_city,
                                color: Colors.brown),
                            title: Text('Address: $address'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email, color: Colors.red),
                            title: Text('Email: $email'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.password, color: Colors.cyan),
                            title: Text('Password: $password'),
                          ),
                          const SizedBox(height: 90),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () {
                                  print(
                                      "First Name: ${Provider.of<AddressProvider>(context).completeAddress}");
                                  _showAddCaregiverDialog(context);

                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //       builder: (context) =>
                                  //           const CreateProfileNamePage()),
                                  // );
                                },
                                child: const Text(
                                  "Confirm",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
