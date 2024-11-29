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
      title: 'Dietary', // 앱 제목
      theme: ThemeData(
        primaryColor:
            const Color.fromARGB(255, 213, 232, 210), // 체크박스나 스위치 활성화 색상
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromARGB(255, 213, 232, 210), // 버튼 색상
        ),
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 255, 255, 255), // 기본 배경 색상
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor:
                  const Color.fromARGB(255, 213, 232, 210)), // 텍스트 버튼 색상
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(secondary: const Color.fromARGB(255, 213, 232, 210)),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(255, 213, 232, 210);
            }
            return null;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(255, 213, 232, 210);
            }
            return null;
          }),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(255, 213, 232, 210);
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return null;
            }
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(255, 213, 232, 210);
            }
            return null;
          }),
        ),
      ),
      home: const LoginScreen(), // 시작 화면
    );
  }
}
