import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();

  bool isEditing = false; // 수정 모드 상태 변수

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data() as Map<String, dynamic>;
          userName = userData!['name'];
          userAge = userData!['age'];
          userGender = userData!['gender'];
          userHeight = userData!['height'];
          currentWeight = userData!['currentWeight'];
          targetWeight = userData!['targetWeight'];

          // Initialize controllers with current values
          ageController.text = userAge?.toString() ?? '';
          heightController.text = userHeight?.toString() ?? '';
          currentWeightController.text = currentWeight?.toString() ?? '';
          targetWeightController.text = targetWeight?.toString() ?? '';
        });
      } else {
        print("No data found for the user.");
      }
    } else {
      print("No user is logged in.");
    }
  }

  Future<void> updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'age': int.tryParse(ageController.text) ?? userAge,
        'height': double.tryParse(heightController.text) ?? userHeight,
        'currentWeight':
            double.tryParse(currentWeightController.text) ?? currentWeight,
        'targetWeight':
            double.tryParse(targetWeightController.text) ?? targetWeight,
      });

      // Reload data to reflect updates
      loadUserData();
    }
  }

  Widget _buildEditableInfoRow(
      String label, TextEditingController controller, TextInputType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 132, 195, 135)),
        ),
        SizedBox(
          width: 150,
          child: TextField(
            controller: controller,
            keyboardType: type,
            textAlign: TextAlign.end,
            decoration: const InputDecoration(border: InputBorder.none),
            enabled: isEditing, // 수정 가능 여부
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('images/profile.png'),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                userName ?? 'Loading...',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 132, 195, 135)),
              ),
              const SizedBox(height: 30),
              // Editable user details section
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildEditableInfoRow(
                        '나이',
                        ageController,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildInfoRow('성별',
                          userGender ?? 'Loading...'), // Non-editable for now
                      const SizedBox(height: 10),
                      _buildEditableInfoRow(
                        '키',
                        heightController,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildEditableInfoRow(
                        '현재 몸무게',
                        currentWeightController,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      _buildEditableInfoRow(
                        '목표 몸무게',
                        targetWeightController,
                        TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    // 수정 완료 버튼 동작
                    updateUserData();
                  }
                  setState(() {
                    isEditing = !isEditing; // 수정 모드 토글
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 132, 195, 135),
                ),
                child: Text(
                  isEditing ? '수정 완료' : '수정하기',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 132, 195, 135)),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ],
    );
  }
}
