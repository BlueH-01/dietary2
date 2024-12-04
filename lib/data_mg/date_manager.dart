import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import '../data_mg/nutrition_manager.dart';

class DateManager {
  final FirebaseFirestore firestore; // Firestore 인스턴스
  final String userId; // 현재 사용자 ID
  DateTime selectedDate; // 현재 선택 날짜

  // final NutritionManager nutritionManager; // NutritionManager 인스턴스

  // 영양소 데이터
  double calories = 0;
  double carbs = 0;
  double proteins = 0;
  double fats = 0;

  late Map<String, Map<String,dynamic>> mealData;

  DateManager({
    required this.firestore,
    required this.userId, // Id - 현재 사용자
    DateTime? initialDate, // 초기 날짜 - 오늘 날짜로 설정
  }) : selectedDate = initialDate ?? DateTime.now() {
    mealData = _initializeMealData();
  }

  // 현재 선택된 날짜의 포맷
  String formattedDate() {
    return "${selectedDate.toLocal()}".split(' ')[0];
  }

      // 초기 식사 데이터 생성
  Map<String, Map<String, dynamic>> _initializeMealData() {
    return {
      "아침": _emptyMeal(),
      "점심": _emptyMeal(),
      "저녁": _emptyMeal(),
      "간식": _emptyMeal(),
    };
  }

    // 빈 식사 데이터
  Map<String, dynamic> _emptyMeal() {
    return {
      "name": "없음",
      "calories": 0.0,
      "carbs": 0.0,
      "proteins": 0.0,
      "fats": 0.0,
    };
  }

  void _updateFromData(Map<String, dynamic> data) {
    calories = (data['calories'] ?? 0).toDouble();
    carbs = (data['carbs'] ?? 0).toDouble();
    proteins = (data['proteins'] ?? 0).toDouble();
    fats = (data['fats'] ?? 0).toDouble();
    mealData = Map<String, Map<String, dynamic>>.from(
      data['meals'] ?? _initializeMealData());
  }

  // 데이터 초기화
  void resetData() {
    calories = 0;
    carbs = 0;
    proteins = 0;
    fats = 0;
    mealData = _initializeMealData();
  }

  // 전체 합산 데이터 업데이트
  void updateTotalData() {
    calories = 0;
    carbs = 0;
    proteins = 0;
    fats = 0;

    mealData.forEach((key, value) {
      calories += value['calories'];
      carbs += value['carbs'];
      proteins += value['proteins'];
      fats += value['fats'];
    });
  }


  // Firestore에서 날짜별 데이터 불러오기
  Future<void> loadDataForDate({
    required void Function(Map<String, dynamic>) onDataLoaded,
    required VoidCallback onNoData,
  }) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate())
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _updateFromData(data);
        onDataLoaded(data);
      } else {
        resetData();
        onNoData();
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      resetData();
      onNoData();
    }
  }

  // Firestore에 데이터 저장
  Future<void> saveDataForDate() async {
    final data = {
      'calories': calories,
      'carbs': carbs,
      'proteins': proteins,
      'fats': fats,
      'meals': mealData,
    };

    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_data')
          .doc(formattedDate())
          .set(data);
      debugPrint("Data saved successfully!");
    } catch (e) {
      debugPrint("Error saving data: $e");
    }
  }

  // 날짜 변경
  void changeDate(int days, Function(DateTime) onDateChanged) {
    selectedDate = selectedDate.add(Duration(days: days));
    onDateChanged(selectedDate);
  }

  // 날짜 선택
  Future<void> selectDate(
    BuildContext context, {
    required Function(DateTime) onDateSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      onDateSelected(selectedDate);
    }
  }
}
