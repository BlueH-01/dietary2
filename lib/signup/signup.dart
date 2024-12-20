import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dietary2/firebase_init.dart';
import './user_info.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _authentication = FirebaseInit().auth;
  final _formKey = GlobalKey<FormState>();
  String nickname = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  Future<void> _trySignup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 일치하지 않습니다!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final userCredential =
            await _authentication.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('회원가입 성공!'),
              backgroundColor: Color.fromARGB(255, 103, 180, 105),
            ),
          );

          String userId = userCredential.user!.uid;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return UserInfoScreen(
                userId: userId,
              );
            }),
          );
        }
      } catch (error) {
        String errorMessage = '오류가 발생했습니다. 다시 시도해주세요.';
        if (error.toString().contains('email-already-in-use')) {
          errorMessage = '이미 사용 중인 이메일입니다.';
        } else if (error.toString().contains('weak-password')) {
          errorMessage = '비밀번호가 너무 약합니다.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.only(left: 60), // 왼쪽 여백을 추가하여 우측으로 미세 이동
          child: const Text(
            '회원가입',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 132, 195, 135),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ), // 앱바 하단 모서리 둥글게 처리
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '계정을 생성하세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 118, 183, 120),
                  ),
                ),
                const SizedBox(height: 20),

                // 이름 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '이름',
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
                      color: Color.fromARGB(255, 104, 182, 106)), // 글자 색상 변경

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    nickname = value!;
                  },
                ),
                const SizedBox(height: 20),

                // 이메일 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.email,
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
                  style: const TextStyle(color: Colors.white), // 글자 색상 변경

                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return '유효한 이메일을 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value!;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.lock,
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
                  style: const TextStyle(color: Colors.white), // 글자 색상 변경

                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 확인 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 105, 172, 107)),
                    prefixIcon: const Icon(Icons.lock_open,
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
                  style: const TextStyle(color: Colors.white), // 글자 색상 변경
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해주세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    confirmPassword = value!;
                  },
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _trySignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 132, 195, 135),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
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
