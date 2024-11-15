import 'package:flutter/material.dart';
import './firebase_init.dart'; // Firebase 초기화 관리 파일
import 'login/login.dart';

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
      title: 'My InterViewer ', // 앱 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 앱 테마
      ),
      home: const LoginScreen(), // 시작 화면
    );
  }
}
