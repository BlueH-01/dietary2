import 'dart:io'; // File 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // FirebaseStorage 추가
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../settings/notify.dart';
import '../main_home/main_home.dart';

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

  File? _profileImage; // 선택한 이미지 파일

  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController currentWeightController = TextEditingController();
  final TextEditingController targetWeightController = TextEditingController();

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // 프로필 데이터 불러오기
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

          ageController.text = userAge?.toString() ?? '';
          heightController.text = userHeight?.toString() ?? '';
          currentWeightController.text = currentWeight?.toString() ?? '';
          targetWeightController.text = targetWeight?.toString() ?? '';

          // 프로필 이미지 URL 불러오기
          String? profileImageUrl = userData!['profileImage'];
          if (profileImageUrl != null) {
            _profileImage = File(profileImageUrl); // URL을 사용하여 이미지를 로드할 수 있음
          }
        });
      } else {
        print("No data found for the user.");
      }
    } else {
      print("No user is logged in.");
    }
  }

  // 갤러리에서 이미지 선택 후 Firebase Storage에 업로드
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Firebase Storage에 이미지 업로드
      String fileName =
          'profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg';
      File file = File(pickedFile.path);

      try {
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        await storageRef.putFile(file);

        // 업로드한 파일의 URL 가져오기
        String downloadURL = await storageRef.getDownloadURL();

        print("Profile image uploaded. Download URL: $downloadURL");
      } catch (e) {
        print("Error uploading image: $e");
      }
    } else {
      print("No image selected.");
    }
  }

  // 사용자 정보 업데이트 (수정 완료)
  Future<void> updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'age': int.parse(ageController.text),
          'height': double.parse(heightController.text),
          'currentWeight': double.parse(currentWeightController.text),
          'targetWeight': double.parse(targetWeightController.text),
        });

        print("User data updated.");
      } catch (e) {
        print("Error updating user data: $e");
      }
    }
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
        actions: [
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
              size: 30,
              color: Colors.white, // 아이콘 색상을 흰색으로 설정
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        // 스크롤뷰로 감싸기
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // 로컬 이미지
                      : const AssetImage('images/profile.png')
                          as ImageProvider, // 기본 이미지
                )),
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
                    _buildInfoRow('성별', userGender ?? 'Loading...'),
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
                  updateUserData();
                }
                setState(() {
                  isEditing = !isEditing;
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

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
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
          width: 120,
          height: 45,
          child: TextField(
            controller: controller,
            keyboardType: inputType,
            enabled: isEditing,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isEditing
                  ? Colors.grey
                  : Colors.black, // 수정 중일 때 회색, 수정 완료 후 검정색
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // 둥근 모서리
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // 둥근 모서리
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
