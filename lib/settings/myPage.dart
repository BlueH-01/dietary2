import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_home/main_home.dart';
import '../settings/notify.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userData;
  String? userName;
  int? userAge;
  String? userGender;
  double? userHeight;
  double? currentWeight;
  double? targetWeight;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
        });
      } else {
        print("No data found for the user.");
      }
    } else {
      print("No user is logged in.");
    }

    userName = userData!['name'];
    userAge = userData!['age'];
    userGender = userData!['gender'];
    userHeight = userData!['height'];
    currentWeight = userData!['currentWeight'];
    targetWeight = userData!['targetWeight'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationService(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications,
                    size: 40,
                  ),
                ),
              ],
            ),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            Align(
              alignment: Alignment.center,
              child: Text(
                '$userName',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 65),
            _buildInfoRow('나이', '${userAge}'),
            SizedBox(height: 16),
            _buildInfoRow('성별', '${userGender}'),
            SizedBox(height: 16),
            _buildInfoRow('키', '${userHeight}'),
            SizedBox(height: 16),
            _buildInfoRow('현재 몸무게', '${currentWeight} kg'),
            SizedBox(height: 16),
            _buildInfoRow('목표 몸무게', '${targetWeight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
