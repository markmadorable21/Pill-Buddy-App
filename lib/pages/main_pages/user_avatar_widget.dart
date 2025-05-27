import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  final double radius;

  const UserAvatarWidget({super.key, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage("assets/images/user_photo1.png"),
      );
    }

    final userDoc =
        FirebaseFirestore.instance.collection('patients').doc(user.uid);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show placeholder avatar while loading
          return CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage("assets/images/user_photo1.png"),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage("assets/images/user_photo1.png"),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final avatarUrl = data?['avatarUrl'];

        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: NetworkImage(avatarUrl),
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage("assets/images/user_photo1.png"),
          );
        }
      },
    );
  }
}
