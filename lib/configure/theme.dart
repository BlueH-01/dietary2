import 'package:flutter/material.dart';

// 앱의 테마를 반환하는 함수
ThemeData buildThemeData() {
  const primaryColor = Color.fromARGB(255, 213, 232, 210);

  return ThemeData(
    primaryColor: primaryColor, // 체크박스나 스위치 활성화 색상
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor, // 버튼 색상
    ),
    scaffoldBackgroundColor:
        const Color.fromARGB(255, 255, 255, 255), // 기본 배경 색상
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor, // 텍스트 버튼 색상
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
        .copyWith(secondary: primaryColor),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        },
      ),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        },
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        },
      ),
    ),
  );
}
