import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_buddy/pages/providers/medication_provider.dart';
import 'package:provider/provider.dart';

class UserNameWidget extends StatelessWidget {
  const UserNameWidget({super.key, this.textColor = Colors.black});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool isCaregiver =
        Provider.of<MedicationProvider>(context, listen: false).isCaregiver;
    if (user == null) {
      return Text(
        "No User",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
    }

    final userDoc = isCaregiver
        ? FirebaseFirestore.instance.collection('caregivers').doc(user.uid)
        : FirebaseFirestore.instance.collection('patients').doc(user.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(color: textColor);
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "No Name",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? "No Name";

        return Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        );
      },
    );
  }
}
