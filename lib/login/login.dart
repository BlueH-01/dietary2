import 'package:dietary2/signup/signup.dart';
import 'package:flutter/material.dart';
import 'package:dietary2/firebase_init.dart';
import 'package:dietary2/configure/palette.dart';
import 'package:dietary2/main_home/main_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authentication = FirebaseInit().auth;

  bool isSignupScreen = true; // 사인업 관리
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String userEmail = '';
  String userPassword = '';

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate(); //null 체크 form의 유효성 검사
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 화면 터치 시 키보드 숨기기
        },
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/diet.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(top: 90, left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Dietary ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            fontSize: 38,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //배경
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              top: keyboardHeight > 0
                  ? 500 - keyboardHeight
                  : 400, // 키보드 높이에 따라 이동
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                padding: const EdgeInsets.all(20),
                height: 240.0,
                width: MediaQuery.of(context).size.width - 40,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      )
                    ]),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSignupScreen = false;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !isSignupScreen
                                        ? Palette.activeColor
                                        : Palette.textColor1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 9),
                              TextFormField(
                                key: const Key('login_email'),
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return '유효한 이메일 주소를 입력하세요';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  userEmail = value!;
                                },
                                onChanged: (value) {
                                  userEmail = value;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Palette.iconColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  hintText: '이메일',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textColor1,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(height: 15), // 공간 조정
                              TextFormField(
                                obscureText: true,
                                key: const Key('login_password'),
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 6) {
                                    return '7글자 이상 입력하세요';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  userPassword = value!;
                                },
                                onChanged: (value) {
                                  userPassword = value;
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock, // 비밀번호 필드에는 일반적으로 자물쇠 아이콘을 사용
                                    color: Palette.iconColor,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Palette.textColor1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(35.0),
                                    ),
                                  ),
                                  hintText: '비밀번호',
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    color: Palette.textColor1,
                                  ),
                                  contentPadding: EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(height: 8), // 로그인 상태에서 필드 간 여백을 조정
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Login 화면의 body Stack 아래 부분에 추가
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const SignupScreen();
                      }),
                    );
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 213, 232, 210),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "회원가입",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            //텍스트 폼 필드
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              top: keyboardHeight > 0
                  ? keyboardHeight + 50 // 키보드 높이에 따라 화살표 위치 조정
                  : 600.0, // 기본 위치
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  height: 80, //화살표 동그라미 크기
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50)),
                  child: GestureDetector(
                    onTap: () async {
                      if (isSignupScreen) {
                        try {
                          final newUser = await _authentication
                              .createUserWithEmailAndPassword(
                                  email: userEmail, password: userPassword);
                          if (newUser.user != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return const MainScreen();
                              }),
                            );
                          }
                        } catch (e) {}
                      }
                      _tryValidation();

                      try {
                        _tryValidation();
                        final newUser =
                            await _authentication.signInWithEmailAndPassword(
                                email: userEmail, password: userPassword);
                        if (newUser.user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return const MainScreen();
                            }),
                          );
                        }
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('이메일과 비밀번호를 확인하세요'),
                            backgroundColor: Color.fromARGB(255, 195, 73, 52),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(
                                    255, 233, 236, 232), //화살표 동그라미 색상
                                Color.fromARGB(255, 213, 232, 210),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ]),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            //전송 버튼
          ],
        ),
      ),
    );
  }
}
