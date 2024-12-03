import 'package:flutter/material.dart';
import './firebase_init.dart'; // Firebase 초기화 관리 파일
import 'login/login.dart'; // 로그인 화면
import './configure/theme.dart'; // 테마 관리 파일

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 바인딩 초기화
  await FirebaseInit().initializeFirebase(); // Firebase 초기화
  runApp(
    const MyApp(),
  ); // 앱 실행
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietary', // 앱 제목
      theme: buildThemeData(), // 테마 적용
      home: const LoginScreen(), // 시작 화면
    );
  }
}
