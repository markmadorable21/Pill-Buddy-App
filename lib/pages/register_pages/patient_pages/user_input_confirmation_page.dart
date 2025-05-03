import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:pill_buddy/pages/add_caregiver_family_pages/add_new_caregiver_family_page.dart';
import 'package:pill_buddy/pages/main_pages/main_page.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:pill_buddy/pages/providers/address_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInputConfirmationPage extends StatefulWidget {
  const UserInputConfirmationPage({super.key});

  @override
  State<UserInputConfirmationPage> createState() =>
      _UserInputConfirmationPage();
}

class _UserInputConfirmationPage extends State<UserInputConfirmationPage> {
  final Logger logger = Logger();
  late final ImagePicker _picker;
  late final CloudinaryPublic _cloudinary;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    // Initialize CloudinaryPublic with your Cloudinary account details
    _cloudinary = CloudinaryPublic(
      'dnjab51pg', // e.g. "demo"
      'flutter_avatar_upload', // unsigned preset name
      cache: false,
    );
  }

  Future<void> _pickImage() async {
    final pickedSource = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera, color: Colors.green),
            title: const Text('Take a Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_album, color: Colors.green),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
    if (pickedSource == null) return;
    try {
      final pickedFile = await _picker.pickImage(source: pickedSource);
      if (pickedFile != null) setState(() => _imageFile = pickedFile);
    } catch (e) {
      logger.e('Error picking image: $e');
    }
  }

  /// Uploads image to Cloudinary and notifies provider
  Future<String?> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return null;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Uploading image...')),
    );
    try {
      final res = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(_imageFile!.path,
            resourceType: CloudinaryResourceType.Image),
      );
      final url = res.secureUrl;
      // Save URL in provider
      context.read<MedicationProvider>().setAvatarUrl(url);
      // Also write user profile to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': context.read<MedicationProvider>().completeName,
          'birthdate': context.read<MedicationProvider>().birthDateFormatted,
          'age': context.read<MedicationProvider>().calculatedAge,
          'gender': context.read<MedicationProvider>().selectedGender,
          'address': context.read<AddressProvider>().completeAddress,
          'email': context.read<MedicationProvider>().inputtedEmail,
          'password': context.read<MedicationProvider>().inputtedPassword,
          'avatarUrl': url,
        });
      }
      return url;
    } catch (e) {
      logger.e('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload error: $e')),
      );
      return null;
    }
  }

  void _showAddCaregiverDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add,
                  size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Would you like to add a caregiver (family or relative) to help you monitor your medications?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Add Existing User',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddNewCaregiverFamilyPage()));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue),
                child: const Text('Add New Caregiver/Family',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const MainPage()));
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary)),
                child: Text('Later',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final medProv = context.read<MedicationProvider>();
    final addressProv = context.watch<AddressProvider>();

    final completeName = medProv.completeName;
    final birthdate = medProv.birthDateFormatted;
    final age = medProv.calculatedAge;
    final email = medProv.inputtedEmail;
    final password = medProv.inputtedPassword;
    final gender = medProv.selectedGender;
    final address = addressProv.completeAddress.isEmpty
        ? 'No address provided'
        : addressProv.completeAddress;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with avatar picker
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 7,
                    offset: const Offset(0, 3))
              ],
            ),
            height: MediaQuery.of(context).size.height * 0.25,
            width: double.infinity,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _imageFile == null
                      ? CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person,
                              size: 130, color: Colors.grey[400]),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: primaryColor, width: 3)),
                          child: CircleAvatar(
                              radius: 90,
                              backgroundImage:
                                  FileImage(File(_imageFile!.path))),
                        ),
                ),
              ),
            ),
          ),
          // Details list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                const Center(
                    child: Text('Tap the icon to change your profile picture',
                        style: TextStyle(fontSize: 15, color: Colors.grey))),
                const SizedBox(height: 10),
                ListTile(
                    leading: const Icon(LucideIcons.user, color: Colors.blue),
                    title: Text('Name: $completeName')),
                ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.green),
                    title: Text('Birthdate: $birthdate')),
                ListTile(
                    leading: const Icon(Icons.cake, color: Colors.orange),
                    title: Text('Age: $age')),
                ListTile(
                    leading: const Icon(Icons.male, color: Colors.purple),
                    title: Text('Gender: $gender')),
                ListTile(
                    leading:
                        const Icon(Icons.location_city, color: Colors.brown),
                    title: Text('Address: $address')),
                ListTile(
                    leading: const Icon(Icons.email, color: Colors.red),
                    title: Text('Email: $email')),
                ListTile(
                    leading: const Icon(Icons.password, color: Colors.cyan),
                    title: Text('Password: $password')),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Confirm button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final imageUrl = await _uploadImage();
                  if (imageUrl != null) {
                    logger.i('Uploaded image URL: $imageUrl');
                    // TODO: Save imageUrl to your database
                  }
                  _showAddCaregiverDialog();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('Confirm',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
