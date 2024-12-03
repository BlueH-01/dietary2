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
        title: const Text('My Profile',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
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
                    color: Color.fromARGB(255, 132, 195, 135),
                  ),
                ),
              ),
              Center(
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('images/profile.png'),
                ),
              ),
              SizedBox(height: 10),
              Text(
                userName ?? 'Loading...',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 132, 195, 135)),
              ),
              SizedBox(height: 30),
              // User details section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildInfoRow('나이', '${userAge ?? 'Loading...'}'),
                      SizedBox(height: 10),
                      _buildInfoRow('성별', '${userGender ?? 'Loading...'}'),
                      SizedBox(height: 10),
                      _buildInfoRow('키', '${userHeight ?? 'Loading...'}'),
                      SizedBox(height: 10),
                      _buildInfoRow(
                          '현재 몸무게', '${currentWeight ?? 'Loading...'} kg'),
                      SizedBox(height: 10),
                      _buildInfoRow(
                          '목표 몸무게', '${targetWeight ?? 'Loading...'} kg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 132, 195, 135)),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ],
    );
  }
}
