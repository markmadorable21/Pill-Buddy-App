import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic> userData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    final doc = await firestore.collection('patients').doc(user!.uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data() ?? {};
        isLoading = false;
      });
    }
  }

  Future<void> _editField(String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: field),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Confirm')),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty && newValue != currentValue) {
      await _updateUserData(field, newValue);
    }
  }

  Future<void> _updateUserData(String field, String newValue) async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await firestore
          .collection('patients')
          .doc(user!.uid)
          .update({field: newValue});
      setState(() {
        userData[field] = newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$field updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update $field: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        children: userData.entries.map((entry) {
          final field = entry.key;
          final value = entry.value?.toString() ?? '';

          return ListTile(
            title: Text(
              field[0].toUpperCase() +
                  field.substring(1), // Capitalize field name
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(value),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editField(field, value),
            ),
          );
        }).toList(),
      ),
    );
  }
}
