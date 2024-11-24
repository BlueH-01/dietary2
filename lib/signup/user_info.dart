import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dietary2/firebase_init.dart';

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
        title: const Text('회원 정보 입력'),
        backgroundColor: Colors.blue,
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
                // 나이 입력 필드
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '나이',
                    border: OutlineInputBorder(),
                  ),
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
                  decoration: const InputDecoration(
                    labelText: '성별',
                    border: OutlineInputBorder(),
                  ),
                  value: userGender,
                  items: genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      userGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // 키 입력 필드
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '키 (cm)',
                    border: OutlineInputBorder(),
                  ),
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
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '현재 체중 (kg)',
                    border: OutlineInputBorder(),
                  ),
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
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '목표 체중 (kg)',
                    border: OutlineInputBorder(),
                  ),
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
                              .collection(widget.userId) // `users` 컬렉션 선택
                              .doc('userInfo') // userId로 문서 선택
                              .set({
                            'age': userAge,
                            'gender': userGender,
                            'height': userHeight,
                            'currentWeight': currentWeight,
                            'targetWeight': targetWeight,
                          });

                          print('Firestore 저장 성공');
                          print('나이: $userAge');
                          print('성별: $userGender');
                          print('키: $userHeight cm');
                          print('현재 체중: $currentWeight kg');
                          print('목표 체중: $targetWeight kg');

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('회원 정보가 Firestore에 저장되었습니다!')),
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
