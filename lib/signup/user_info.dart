import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dietary2/firebase_init.dart';
import '../main_home/main_home.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;
  const UserInfoScreen({super.key, required this.userId}); // 생성자에 userId 추가

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore firestore = FirebaseInit().firestore;

  // 사용자 정보 변수
  String userName = "";
  int userAge = 0;
  String userGender = '여성'; // 기본값
  double userHeight = 0.0;
  double currentWeight = 0.0;
  double targetWeight = 0.0;
  List<String> genders = ['남성', '여성', '기타'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원 정보 입력',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 118, 193, 120),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원 정보를 입력해주세요.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // 이름 입력 필드

                TextFormField(
                  decoration: InputDecoration(
                    labelText: '이름',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.account_circle,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 213, 232, 210),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 182, 106)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    userName = value!;
                  },
                ),

                const SizedBox(height: 20),
                // 나이 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '나이',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 213, 232, 210),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 182, 106)), // 글자 색상
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '나이를 입력해주세요.';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return '유효한 나이를 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    userAge = int.parse(value!);
                  },
                ),
                const SizedBox(height: 20),

                // 성별 선택 드롭다운
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: '성별',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.transgender,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor:
                        const Color.fromARGB(255, 232, 245, 233), // 다른 배경색
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  value: userGender,
                  items: genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(
                        gender,
                        style: const TextStyle(
                            color:
                                Color.fromARGB(255, 60, 120, 60)), // 텍스트 색상 변경
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      userGender = value!;
                    });
                  },
                  dropdownColor: const Color.fromARGB(
                      255, 220, 240, 220), // 드롭다운 메뉴 배경색 변경
                ),

                const SizedBox(height: 20),
                // 키 입력 필드

                TextFormField(
                  decoration: InputDecoration(
                    labelText: '키',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 213, 232, 210),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 182, 106)), // 글자 색상
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '키를 입력해주세요.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return '유효한 키를 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    userHeight = double.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                // 현재 체중 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '현재 체중',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.fitness_center,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 213, 232, 210),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 182, 106)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '현재 체중을 입력해주세요.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return '유효한 체중을 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    currentWeight = double.parse(value!);
                  },
                ),
                const SizedBox(height: 20),
                // 목표 체중 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '목표 체중',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.person,
                        color: Color.fromARGB(255, 104, 182, 106)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 213, 232, 210),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 104, 182, 106)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(
                      color: Color.fromARGB(255, 104, 182, 106)), // 글자 색상
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '목표 체중을 입력해주세요.';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return '유효한 목표 체중을 입력해주세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    targetWeight = double.parse(value!);
                  },
                ),

                const SizedBox(height: 30),
                // 제출 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        // Firestore에 사용자 정보 저장
                        try {
                          await firestore
                              .collection('users') // `users` 컬렉션 고정
                              .doc(widget.userId) // userId로 문서 선택
                              .set({
                            'name': userName,
                            'age': userAge,
                            'gender': userGender,
                            'height': userHeight,
                            'currentWeight': currentWeight,
                            'targetWeight': targetWeight,
                          });

                          print('Firestore 저장 성공');
                          print('이름: $userName');
                          print('나이: $userAge');
                          print('성별: $userGender');
                          print('키: $userHeight cm');
                          print('현재 체중: $currentWeight kg');
                          print('목표 체중: $targetWeight kg');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('회원 정보가 Firestore에 저장되었습니다!')),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return const MainScreen();
                            }),
                          );
                        } catch (e) {
                          print('Firestore 저장 실패: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('회원 정보 저장에 실패했습니다. 다시 시도해주세요.')),
                          );
                        }
                      }
                    },
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
